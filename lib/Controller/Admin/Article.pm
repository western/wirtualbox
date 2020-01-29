
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
    
    
    
    
    my $filter_page = $r->param('filter_page') || 1;
    $filter_page = int $filter_page;
    my $list_limit = 15.0;
    my $list_offset = ($filter_page-1) * $list_limit;
    
    my $list = $r->model->Article->join('left user')->join('left region')->limit($list_limit)->offset($list_offset)->list( -flat=>1, -json=>1, -row_as_obj=>'row' );
    my $list_count = $r->model->Article->join('left user')->count;
    
    
    
    
    
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
        h1_title    => 'Article edit',
    );
}

sub new {
    my($self, $r, $args) = @_;
    
    $r->response->template_file('edit');
    
    my $region_list = $r->model->Region->list( -data=>1, -map=>sub{ [$_[0]->{id}, $_[0]->{title}] } );
    
    $r->response->template_args(
        
        region_list => JSON::XS->new->utf8->encode($region_list),
        h1_title    => 'Article new',
    );
}

sub create {
    my($self, $r, $args) = @_;
    
    
}

1;
