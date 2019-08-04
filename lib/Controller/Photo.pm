
package Controller::Photo;

use WB::Util qw(dumper);


sub index{
    warn __PACKAGE__." index call";
    warn "dumper ".dumper(\@_);
}

1;
