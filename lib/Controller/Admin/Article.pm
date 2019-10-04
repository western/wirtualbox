
package Controller::Admin::Article;

use utf8;
use WB::Util qw(:def);
use WB::Model;

use Model::Article;

required 'App::auth_required';
template_layout 'vue';

sub index {
    my($self, $r, $args) = @_;
    
    
    #die dumper $r->model->db;
    #die dumper $r->model->Article->db;
    #die dumper $r->model->Article->list;
    #die $r->model->Article->list->[0]->{registered}->value;
    
    
}

1;
