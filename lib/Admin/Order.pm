
package Admin::Order;

use utf8;
use WB::Util qw(:def);
use Controller::Helper;

required 'Application::auth_required';
template_layout 'admin';

sub index{
    my($o, $r, $args) = @_;
    
    $r->response->template_args(
        is_auth => Controller::Helper::is_auth($r, $args),
        head_title => 'Заявки',
        nav_highlight_order => 'active',
    );
}

sub list{
    my($o, $r, $args) = @_;
    
    my $db = $r->db;
    my $list = $db->selectall_arrayref('select * from orders');
    
    $r->response->json(
        
    );
}

1;
