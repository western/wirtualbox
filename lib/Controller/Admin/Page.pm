
package Controller::Admin::Page;

use utf8;
use WB::Util qw(:def);
use Controller::Helper;

required 'App::auth_required';
template_layout 'admin';

sub index{
    my($o, $r, $args) = @_;
    
    #my $list_vms = $r->vboxmanage->list_vms;
    
    
    
    $r->response->template_args(
        is_auth => Controller::Helper::is_auth($r, $args),
        #list_vms => $list_vms,
        head_title => 'Dasnboard',
        nav_highlight_index => 'active',
    );
}


1;
