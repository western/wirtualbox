
package Controller::Application;

use utf8;
use WB::Util qw(:def);


sub auth_required{
    my($o, $r, $args) = @_;
    
    if( my $auth = $r->cookie('auth') ){
        return 1;
    }else{
        $r->response->set403();
    }
    
    0;
}

1;
