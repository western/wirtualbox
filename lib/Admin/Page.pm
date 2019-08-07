
package Admin::Page;

use utf8;
use WB::Util qw(:def);
use Controller::Helper;

required 'Application::auth_required';
template_layout 'admin';

sub index{
    my($o, $r, $args) = @_;
    
    $r->response->template_args(
        is_auth => Controller::Helper::is_auth($r, $args),
        head_title => 'Dasnboard',
        nav_highlight_index => 'active',
    );
}


1;
