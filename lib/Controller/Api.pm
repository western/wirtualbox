
package Controller::Api;

use utf8;
use WB::Util qw(:def);

required 'App::auth_required_json';
template_layout 'none';



sub model {
    my($self, $r, $args) = @_;
    
    my $name = $args->{name} || '';
    my $id   = $args->{id} || '';
    
    return $r->response->json(
        code => 'err',
        msg  => 'model name is bad'
    ) if ( $name !~ m!^\w+$!i );
    
    return $r->response->json(
        code => 'err',
        msg  => 'model id is bad'
    ) if ( $id !~ m!^\d+$! );
    
    my $model = $r->model->get_model($name);
    return $r->response->json(
        code => 'err',
        msg  => "model $name is not found"
    ) if ( !$model );
    
    $model = $model->where( id => $id )->limit(1)->list( -flat=>1, -json=>0 )->[0];
    return $r->response->json(
        code => 'err',
        msg  => "model $name [$id] is not found"
    ) if ( !$model );
    
    
    $r->response->json(
        code  => 'ok',
        model => $model,
    );
}

1;
