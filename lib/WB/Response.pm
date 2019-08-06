
package WB::Response;

use strict;
use warnings;

use Cookie::Baker ();
use JSON::XS;
use Crypt::CBC;

use WB::Util qw(dumper);
use WB::Template;


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $o = {
        code => 200,
        header => [],
        cookie => [],
        body => [],
        
        template_engine => '',
        template_object => undef,
        template_args => {},
        mode => 'body', # body, template, json
        %arg,
    };
    
    if( scalar @{$o->{header}} == 0 ){
        push @{$o->{header}}, ('Content-type', 'text/html;charset=utf-8');
        push @{$o->{header}}, ('X-WB', '1');
    }
    
    if( $o->{template_engine} ){
        
        my $t = new WB::Template(
            template_engine => $o->{template_engine},
        );
        $t->init();
        
        $o->{template_object} = $t;
        $o->{mode} = 'template';
    }
    
    bless $o, $class;
}

sub mode{
    my $o = shift;
    my $arg = shift;
    $o->{mode} = $arg if ($arg);
    $o->{mode};
}

sub code{
    my $o = shift;
    my $arg = shift;
    $o->{code} = $arg if ($arg);
    $o->{code};
}

sub header{
    my $o = shift;
    my $name = shift;
    my $value = shift;
    
    push @{$o->{header}}, ($name, $value) if ($name);
    $o->{header};
}

=head1 cookie

    cookie(
        name => '',
        value => '',
        path => '',
        domain => '',
        expires => '+24h',
    )

=cut
sub cookie{
    my $o = shift;
    my %arg = @_;
    
    if( $arg{json} && $arg{value} ){
        $arg{value} = JSON::XS->new->utf8->encode($arg{value});
    }
    
    if( $arg{crypt} && $arg{value} ){
        my $cipher = Crypt::CBC->new(
            -key => $o->{secret},
            -cipher => 'Blowfish'
        );
        $arg{value} = $cipher->encrypt_hex($arg{value});
    }
    
    push @{$o->{cookie}}, Cookie::Baker::bake_cookie($arg{name}, {
        %arg,
    });
}

sub body{
    my $o = shift;
    
    push @{$o->{body}}, @_ if (@_);
    $o->{body};
}

sub json{
    my $o = shift;
    $o->{mode} = 'json';
    
    push @{$o->{body}}, @_ if (@_);
    $o->{body};
}

sub template_file{
    my $o = shift;
    my $file = shift;
    my $template_main = shift;
    my $to = $o->{template_object};
    
    if( $file && $to ){
        $to->template_file( $file, $template_main );
    }
}

sub template_args{
    my $o = shift;
    my %args = @_;
    
    $o->{template_args} = \%args if (@_);
    $o->{template_args};
}

sub set404{
    my $o = shift;
    $o->{mode} = 'body';
    $o->{code} = 404;
    $o->{body} = [
        '<h1>404 Not Found</h1><hr>',
        $o->{env}{PATH_INFO},
    ];
}

sub set301{
    my $o = shift;
    my $goto = shift;
    
    $o->{header} = ['Location', $goto];
    
    $o->{mode} = 'body';
    $o->{code} = 301;
    $o->{body} = [];
}

sub set403{
    my $o = shift;
    $o->{mode} = 'body';
    $o->{code} = 403;
    $o->{body} = [
        '<h1>403 Forbidden</h1><hr>',
        $o->{env}{PATH_INFO},
    ];
}

sub out{
    my $o = shift;
    my $body = $o->{body};
    
    if( $o->{mode} eq 'template' ){
        $body = [ $o->{template_object}->process( %{$o->{template_args}} ) ];
    }
    
    if( $o->{mode} eq 'json' ){
        $o->{header} = [];
        push @{$o->{header}}, ('Content-type', 'application/json;charset=utf-8');
        push @{$o->{header}}, ('X-WB', '1');
        
        $body = [ JSON::XS->new->utf8->encode($body->[0]) ];
    }
    
    for my $c (@{$o->{cookie}}){
        push @{$o->{header}}, 'Set-Cookie' => $c;
    }
    
    return [
        $o->{code},
        $o->{header},
        $body,
    ];
}

1;
