
package Controller::Api;

use WB::Util qw(dumper);


sub index{
    warn __PACKAGE__." index call";
    warn "dumper ".dumper(\@_);
}

sub post{
    warn __PACKAGE__." post call";
    warn "dumper ".dumper(\@_);
}

1;
