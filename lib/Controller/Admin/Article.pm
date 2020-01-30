
package Controller::Admin::Article;

use utf8;
use WB::Util qw(:def);
use POSIX;



required 'App::auth_required';
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
    
    
    
    $r->response->template_args(
        
        list        => $list,
        
        list_count  => $list_count,
        list_pages  => $list_pages,
        filter_page => $filter_page,
        
        region_list => $r->model->Region->list( -data=>1, -map=>sub{ [$_[0]->{id}, $_[0]->{title}] }, -json_all=>1 ),
    );
}

sub edit {
    my($self, $r, $args) = @_;
    
    
    my $data = $r->model->Article->join('left uploadfile as artphoto')->where('article.id' => $args->{id})->list( -flat=>1, -json=>1 )->[0];
    
    #die dumper $data;
    
    if( !$data ){
        return $r->response->template404(
            file       => '404',
            msg        => 'Article '.$args->{id}.' is not found',
            is_article => 1,
        );
    }
    
    
    
    
    $r->response->template_args(
        data        => $data,
        region_list => $r->model->Region->list( -data=>1, -map=>sub{ [$_[0]->{id}, $_[0]->{title}] }, -json_all=>1 ),
        h1_title    => 'Article edit',
    );
}

sub new {
    my($self, $r, $args) = @_;
    
    $r->response->template_file('edit');
    
    $r->response->template_args(
        region_list => $r->model->Region->list( -data=>1, -map=>sub{ [$_[0]->{id}, $_[0]->{title}] }, -json_all=>1 ),
        h1_title    => 'Article new',
    );
}

sub create {
    my($self, $r, $args) = @_;
    my @fields = qw(title status body region_id);
    
    for my $n (@fields){
        
        return $r->response->json({
            code => 'err',
            err  => "Essential field $n is empty",
        }) if ( !$r->param($n) );
    }
    
    my $uploadfile;
    if( my $photo = $r->param('photo') ){
        
        $photo->upload_to(
            full_path => $r->{env}{root}.'/htdocs/file/'.$photo->filename,
        );
        
        $uploadfile = $r->model->Uploadfile->insert(
            model      => 'article',
            path       => '/file/'.$photo->filename,
            filename   => $photo->filename,
            ext        => $photo->ext,
            width      => $photo->width,
            height     => $photo->height,
            size       => $photo->size,
            md5        => $photo->md5,
            registered => current_sql_datetime,
        );
    }
    
    my $id = $r->param('id');
    if( $id ){
        
        # remove previous photo
        #if( $uploadfile ){
        #}
        
        my %r = map { $_ => $r->param($_) } @fields;
        $r{for_first_page} = $r->param('for_first_page') || 0;
        $r{changed}        = current_sql_datetime;
        $r{photo}          = $uploadfile->{id} if ($uploadfile);
        
        $r->model->Article->where( id => $id )->update( %r );
        
    }else{
        
        my %r = map { $_ => $r->param($_) } @fields;
        $r{for_first_page} = $r->param('for_first_page') || 0;
        $r{user_id}        = 1;
        $r{registered}     = current_sql_datetime;
        $r{photo}          = $uploadfile->{id} if ($uploadfile);
        
        my $article = $r->model->Article->insert( %r );
        $id = $article->{id};
    }
    
    $r->response->json({
        code => 'ok',
        id   => $id,
    });
}

sub show {
    my($self, $r, $args) = @_;
    
    
    my $data = $r->model->Article->where(id => $args->{id})->list( -flat=>1, -json=>1 )->[0];
    
    if( !$data ){
        return $r->response->template404(
            file       => '404',
            msg        => 'Article '.$args->{id}.' is not found',
            is_article => 1,
        );
    }
    
    $r->response->template_args(
        data        => $data,
        region_list => $r->model->Region->list( -data=>1, -map=>sub{ [$_[0]->{id}, $_[0]->{title}] }, -json_all=>1 ),
        h1_title    => 'Article show',
    );
}

sub del {
    my($self, $r, $args) = @_;
    
    
    my $data = $r->model->Article->where(id => $args->{id})->list( -flat=>1, -json=>1 )->[0];
    
    if( !$data ){
        
        return $r->response->json({
            code => 'err',
            err  => 'Article '.$args->{id}.' is not found',
        });
    }
    
    $r->model->Article->where(id => $args->{id})->delete;
    
    $r->response->json({
        code => 'ok',
    });
}

1;
