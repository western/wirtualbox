
package Controller::Page;

use WB::Util qw(dumper);


sub index{
    my($o, $req, $res, $args) = @_;
    
    $res->body(__PACKAGE__." index call");
    #$res->body(dumper $args);
}



1;
