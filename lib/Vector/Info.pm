
package Vector::Info;

use WB::Util qw(dumper);


sub index{
    warn __PACKAGE__." index call";
    warn __PACKAGE__." dumper ".dumper(\@_);
}

sub simple{
    warn __PACKAGE__." simple call";
    warn __PACKAGE__." dumper ".dumper(\@_);
}

sub hard{
    warn __PACKAGE__." hard call";
    warn __PACKAGE__." dumper ".dumper(\@_);
}

1;
