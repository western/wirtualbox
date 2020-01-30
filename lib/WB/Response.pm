
package WB::Response;

use strict;
use warnings;

use Cookie::Baker ();
use JSON::XS;
use Crypt::CBC;

use WB::Util qw(:def);
use WB::Template;


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        code   => 200,
        header => [],
        cookie => [],
        body   => [],
        
        template_engine => '',
        template_object => undef,
        template_args   => {},
        mode            => 'body', # body, template, json
        %arg,
    };
    
    if ( scalar @{$self->{header}} == 0 ) {
        push @{$self->{header}}, ('Content-type', 'text/html;charset=utf-8');
        push @{$self->{header}}, ('X-WB', '1');
    }
    
    if ( $self->{template_engine} ) {
        
        my $t = new WB::Template(
            template_engine => $self->{template_engine},
        );
        $t->init();
        
        $self->{template_object} = $t;
        $self->{mode}            = 'template';
    }
    
    bless $self, $class;
}

sub mode{
    my $self = shift;
    my $arg = shift;
    $self->{mode} = $arg if ($arg);
    $self->{mode};
}

sub code{
    my $self = shift;
    my $arg = shift;
    $self->{code} = $arg if ($arg);
    $self->{code};
}

sub header{
    my $self = shift;
    my $name = shift;
    my $value = shift;
    
    push @{$self->{header}}, ($name, $value) if ($name);
    $self->{header};
}

=head2 cookie
    
    for parameters read the doc https://metacpan.org/pod/Cookie::Baker
    
    cookie(
        name     => '',
        value    => '',
        path     => '',
        domain   => '',
        expires  => '+24h',
        httponly => 1,
        secure   => 1,
        samesite => 'strict', # strict is recommended, see https://habr.com/ru/post/334856/
        
        json     => 0,
        crypt    => 0,
    )

=cut
sub cookie{
    my $self = shift;
    my %arg = @_;
    
    if ( $arg{json} && $arg{value} ) {
        $arg{value} = JSON::XS->new->utf8->encode($arg{value});
    }
    
    if ( $arg{crypt} && $arg{value} ) {
        
        my $cipher = Crypt::CBC->new(
            -key    => $self->{secret},
            -cipher => 'Blowfish'
        );
        
        $arg{value} = $cipher->encrypt_hex( $arg{value} );
    }
    
    push @{$self->{cookie}}, Cookie::Baker::bake_cookie($arg{name}, {
        %arg,
    });
}

sub body{
    my $self = shift;
    
    push @{$self->{body}}, @_ if (@_);
    $self->{body};
}

=head2 json
    
    $r->response->json(
        ddd  => 'ff',
        a    => 1,
        some => [99, 95, 3],
    );
    
=cut
sub json{
    my $self = shift;
    $self->{mode} = 'json';
    
    push @{$self->{body}}, @_ if (@_);
    $self->{body};
}

sub template_file($$){
    my $self = shift;
    my $file = shift;
    my $template_main = shift;
    my $to = $self->{template_object};
    
    if( $file && $to ){
        
        #warn "[$file] [$template_main]";
        
        $to->{template_change} = 'action';
        $to->template_file( $file, $template_main );
    }
}

sub template_args{
    my $self = shift;
    my %args = @_;
    
    $self->{template_args} = \%args if (@_);
    $self->{template_args};
}

=head2 template404
    
    return $r->response->template404(
        file => '404',
        
        msg        => 'This Article by '.$args->{id}.' is not found',
        is_article => 1,
    );
    
=cut
sub template404{
    my $self = shift;
    my %args = @_;
    
    $self->mode('template');
    $self->code('404');
    $self->template_args(
        %args,
    );
    $self->template_file($args{file});
}

=head2 set404
    
    return $r->response->set404('This Article by '.$args->{id}.' is not found');
    
=cut
sub set404{
    my $self = shift;
    my $msg  = shift || '404 Not Found';
    $self->{mode} = 'body';
    $self->{code} = 404;
    $self->{body} = [
        "<h1>$msg</h1><hr>",
        $self->{env}{PATH_INFO},
    ];
}

sub set301{
    my $self = shift;
    my $goto = shift;
    
    $self->{header} = ['cache-control', 'no-cache', 'Location', $goto];
    
    $self->{mode} = 'body';
    $self->{code} = 301;
    $self->{body} = [];
}

sub set403{
    my $self = shift;
    my $msg  = shift || '403 Forbidden';
    $self->{mode} = 'body';
    $self->{code} = 403;
    $self->{body} = [
        "<h1>$msg</h1><hr>",
        $self->{env}{PATH_INFO},
    ];
}

sub out{
    my $self = shift;
    my $body = $self->{body};
    
    if( $self->{mode} eq 'template' ){
        $body = [ $self->{template_object}->process( %{$self->{template_args}} ) ];
    }
    
    if( $self->{mode} eq 'json' ){
        $self->{header} = [];
        push @{$self->{header}}, ('Content-type', 'application/json;charset=utf-8');
        push @{$self->{header}}, ('X-WB', '1');
        
        # batch each pairs as hash elements
        if ( scalar(@$body) > 1 ) {
            
            my $h = {};
            while (my($name, $value) = splice(@$body, 0, 2)) {
                $h->{$name} = $value;
            }
            $body = [ JSON::XS->new->utf8->encode($h) ];
            
        } else {
            
            $body = [ JSON::XS->new->utf8->encode($body->[0]) ];
        }
    }
    
    for my $c (@{$self->{cookie}}){
        unshift @{$self->{header}}, 'Set-Cookie' => $c;
    }
    
    return [
        $self->{code},
        $self->{header},
        $body,
    ];
}

1;
