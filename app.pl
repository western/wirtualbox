
use strict;
use warnings;

use utf8;

use lib 'lib';
use WB::Router qw(:def);
use WB::Util qw(:def);



my $app = sub {
    
    WB::Router->new(
        
        env => shift,
        template_engine => 'HTML::Template',
        
        db_dsn      => 'DBI:mysql:database=test;host=127.0.0.1',
        db_login    => 'test',
        db_password => 'test',
        
        secret => '0IkJmbamAN@cboU&hHJxtruU1cI!5Lf4',
        
    )->dispatch(
        
        root 'Page::index',
        
        get(  '/auth'        => 'Auth::index' ),
        post( '/auth/login'  => 'Auth::login' ),
        get(  '/auth/logout' => 'Auth::logout' ),
        
        get('/api/model/:name/:id' => 'Api::model'),
        
        get('/admin' => 'Admin::Page::index'),
        scope('/admin' => [
            
            resource 'user',
            resource 'article',
        ]),
        
        get('/test/orm' => 'Test::orm'),
    );
};


=head1        
    
    example call:
    ----------------------------------------------------------------------------
    ->dispatch(
        
        root 'Page::index',
        
        
        get(  '/auth'        => 'Auth::index' ),
        post( '/auth/login'  => 'Auth::login' ),
        get(  '/auth/logout' => 'Auth::logout' ),
        
        get('/admin' => 'Admin::Page::index'),
        
        scope('/admin' => [
            
            get('/vm/:uuid' => 'Admin::Vm::show'),
            get('/vm/new' => 'Admin::Vm::new'),
            
            resource 'photo',
            
            scope('/admin/inside' => [
                
                resource 'doc',
            ]),
        ]),
    );
    
=cut        
