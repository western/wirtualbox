
package Controller::Page;

use utf8;
use WB::Util qw(:def);
use Controller::Helper;


sub index{
    my($o, $r, $args) = @_;
    
    $r->response->template_args(
        is_auth => Controller::Helper::is_auth($r, $args),
    );
}


1;
