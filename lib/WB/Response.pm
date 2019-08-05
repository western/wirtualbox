
package WB::Response;

use strict;
use warnings;

use WB::Util qw(dumper);
use WB::Template;


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $o = {
        code => 200,
        header => [],
        body => [],
        template_engine => '',
        template_object => undef,
        template_args => {},
        mode => 'body', # body, template
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

sub body{
    my $o = shift;
    
    push @{$o->{body}}, @_ if (@_);
    $o->{body};
}

sub template_file{
    my $o = shift;
    my $file = shift;
    my $to = $o->{template_object};
    
    if( $file && $to ){
        $to->template_file( $file );
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
        '<h1>404</h1><hr>',
        $o->{env}{PATH_INFO},
        ' not found',
    ];
}

sub out{
    my $o = shift;
    my $body = $o->{body};
    
    if( $o->{mode} eq 'template' ){
        $body = [ $o->{template_object}->process( %{$o->{template_args}} ) ];
    }
    
    return [
        $o->{code},
        $o->{header},
        $body,
    ];
}

1;
