
package WB::Response;

use strict;
use warnings;

use WB::Util qw(dumper);


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
    
    if( scalar @{$o->{header}} == 0 ){
        push @{$o->{header}}, ('Content-type', 'text/html');
        push @{$o->{header}}, ('X-WB', '1');
    }
    
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
    
    push @{$o->{header}}, ($name, $value) if ($name);
    $o->{header};
}

sub body{
    my $o = shift;
    
    push @{$o->{body}}, @_ if (@_);
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
