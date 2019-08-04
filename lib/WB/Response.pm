
package WB::Response;

use strict;
use warnings;


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $o = {
        code => 200,
        header => [],
        body => [],
        %arg,
    };
    
    bless $o, $class;
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
    
    $o->{header} = push @{$o->{header}}, [$name, $value] if ($name);
    $o->{header};
}

sub body{
    my $o = shift;
    my $name = shift;
    my $value = shift;
    
    $o->{body} = push @{$o->{body}}, [$name, $value] if ($name);
    $o->{body};
}

sub out{
    my $o = shift;
    
    return [
        $o->{code},
        $o->{header},
        $o->{body},
    ];
}

1;
