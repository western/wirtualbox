
package Controller::Admin::Article;

use utf8;
use WB::Util qw(:def);
use WB::Model;
use POSIX;

use Model::Article;

#required 'App::auth_required';
template_layout 'vue';
#template_layout 'admin';

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
    #die dumper $r->model->Article->join( 'left users' )->list()->[0];
    #die dumper $r->model->Article->join( 'comments' )->list()->[0];
    
    #my $all = $r->model->Article->join( 'comments' )->list();
    #die dumper $all;
    
    #my $row = $r->model->Article->join( 'comments' )->list()->[0];
    #die dumper $row->{body};
    
    #my $row = $r->model->Article->select('users.login')->join( 'users' )->join( 'comments' )->list->[0];
    #my $row = $r->model->Article->join( 'users' )->join( 'comments' )->list->[0];
    #die dumper $row;
    
    #my $row = $r->model->Article->join( 'users' )->join( 'comments' )->list( -data=>1 )->[0];
    #my $all = $r->model->Article->join( 'users' )->join( 'comments' )->list( -data=>1 );
    #die dumper $all;
    
    #my $row = $r->model->Article->join( 'left users' )->list( -data=>1 )->[0];
    #die dumper $row;
    
    #my $list = $r->model->Article->join( 'left users' )->gain('comments')->limit(3)->offset(0)->list( -data=>1 );
    #my $row = $r->model->Article->join( 'left users' )->gain('users')->limit(1)->offset(0)->list( -data=>1 )->[0];
    #die dumper $list;
    
    #$r->response->json({
    #    code => 'ok',
    #    row  => $row,
    #});
    
    my $filter_page = $r->param('filter_page') || 1;
    $filter_page = int $filter_page;
    my $list_limit = 15.0;
    my $list_offset = ($filter_page-1) * $list_limit;
    
    my $list = $r->model->Article->join('left users')->join('left regions')->gain('comments')->limit($list_limit)->offset($list_offset)->list( -data=>1 );
    #my $list = $r->model->Article->join('left users')->gain('comments')->list();
    my $list_count = $r->model->Article->join('left users')->count;
    
    
    #die dumper $list->[0];
    
    
    my $list_pages = $list_count / $list_limit;
    $list_pages = ceil $list_pages;
    $list_pages = 1 if $list_pages == 0;
    
    $r->response->template_args(
        list => $list,
        
        list_count  => $list_count,
        list_pages  => $list_pages,
        filter_page => $filter_page,
    );
    
    #die dumper $r->model->Article->join( 'users' )->list->[0];
    #die dumper $r->model->Article->join( 'users' )->list( -flat => 1 )->[0];
    #die dumper $r->model->Article->join( 'users' )->list( -data => 1 )->[0];
    #die dumper $r->model->Article->join( 'users' )->list( -data => 1 );
    
}

sub edit {
    my($self, $r, $args) = @_;
    
    #die dumper $args;
    
    #my $data = $r->model->Article->where(id => $args->{id})->first;
    #my $data = $r->model->Article->where(id => $args->{id}, title => 'title1')->first;
    #my $data = $r->model->Article->where('id = ? and title like ?', $args->{id}, 'title%')->first;
    
    #die $data->{body}->value;
    #die dumper $data;
    
    #my $data = $r->model->Article->where(id => $args->{id})->attach('regions', 'users')->first( -flat=>1, -json=>1 );
    my $data = $r->model->Article->where(id => $args->{id})->first( -data=>1, -json=>1 );
    #die dumper $data;
    if( !$data ){
        return $r->response->set404('This Article by '.$args->{id}.' is not found');
    }
    
    my @regions = map { [$_->{id}, $_->{title}] } @{$r->model->Region->list( -data=>1 )};
    
    $r->response->template_args(
        data => $data,
        regions => JSON::XS->new->utf8->encode(\@regions),
    );
}

1;
