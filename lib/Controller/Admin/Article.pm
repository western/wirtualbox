
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
    
    #$r->model->Article->join( 'users' )->list->[0];
    #$r->model->Article->join( 'left users' )->list->[0];
    #$r->model->Article->join( 'left users' => 'articles.user_id = users.xx' )->list->[0];
    #$r->model->Article->join( 'comments' )->list->[0];
    #$r->model->Article->join( 'left comments' )->list->[0];
    
    #die dumper $r->model->Article->join( 'users' )->list()->[0];
    #die dumper $r->model->Article->join( 'users' )->list->[0];
    #die dumper $r->model->Article->join( 'users' )->list( -flat => 1 )->[0];
    #die dumper $r->model->Article->join( 'users' )->list( -data => 1 )->[0];
    #die dumper $r->model->Article->join( 'users' )->list( -data => 1 );
    
}

1;
