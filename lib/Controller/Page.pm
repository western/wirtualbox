
package Controller::Page;

use WB::Util qw(dumper);


sub index{
    my($o, $req, $res, $args) = @_;
    
    #die 999;
    #warn dumper $req->{env};
    #warn $req->cookie('c_name');
    $res->cookie(name => 'n_cookie', value => 'val-val-val', expires => '+24h');
    
    #$res->body(__PACKAGE__." index call");
    #$res->body(dumper $args);
}



1;
