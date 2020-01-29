
package Controller::Admin::Article;

use utf8;
use WB::Util qw(:def);
use WB::Model;
use POSIX;

use Model::Article;

#required 'App::auth_required';
template_layout 'admin';


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
    
    my $list = $r->model->Article->join('left user')->join('left region')->limit($list_limit)->offset($list_offset)->list( -flat=>1, -json=>1, -row_as_obj=>'row' );
    my $list_count = $r->model->Article->join('left user')->count;
    
    
    #die dumper $list->[0];
    
    
    my $list_pages = $list_count / $list_limit;
    $list_pages = ceil $list_pages;
    $list_pages = 1 if $list_pages == 0;
    
    my $region_list = $r->model->Region->list( -data=>1, -map=>sub{ [$_[0]->{id}, $_[0]->{title}] } );
    
    $r->response->template_args(
        
        list        => $list,
        
        list_count  => $list_count,
        list_pages  => $list_pages,
        filter_page => $filter_page,
        
        region_list => JSON::XS->new->utf8->encode($region_list),
    );
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
    my $data = $r->model->Article->where(id => $args->{id})->list( -flat=>1, -json=>1 )->[0];
    
    if( !$data ){
        return $r->response->template404(
            file => '404',
            msg        => 'This Article by '.$args->{id}.' is not found',
            is_article => 1,
        );
    }
    
    
    my $region_list = $r->model->Region->list( -data=>1, -map=>sub{ [$_[0]->{id}, $_[0]->{title}] } );
    
    $r->response->template_args(
        data        => $data,
        region_list => JSON::XS->new->utf8->encode($region_list),
    );
}

sub new {
    my($self, $r, $args) = @_;
    
    $r->response->template_file('edit');
    
    my $region_list = $r->model->Region->list( -data=>1, -map=>sub{ [$_[0]->{id}, $_[0]->{title}] } );
    
    $r->response->template_args(
        
        region_list => JSON::XS->new->utf8->encode($region_list),
    );
}

sub create {
    my($self, $r, $args) = @_;
    
    
}

1;
