
package Controller::Api;

use WB::Util qw(dumper);


sub index{
    my($o, $req, $res, $args) = @_;
    
    warn __PACKAGE__." index call";
    warn "dumper ".dumper(\@_);
}

sub post{
    my($o, $req, $res, $args) = @_;
    
    warn __PACKAGE__." post call";
    warn "dumper ".dumper(\@_);
}

1;
