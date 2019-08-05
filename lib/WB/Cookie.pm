
package WB::Cookie;

use strict;
use warnings;


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $o = {
        %arg,
    };
    
    bless $o, $class;
}



1;
