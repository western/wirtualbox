
package Controller::Photo;

use WB::Util qw(dumper);


sub index{
    my($o, $req, $res, $args) = @_;
    
    warn __PACKAGE__." index call";
    warn "dumper ".dumper(\@_);
}

1;
