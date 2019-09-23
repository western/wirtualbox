
use strict;
use warnings;

use utf8;

use lib 'lib';
use WB::Router qw(:def);
use VBoxManage;



my $app = sub {
    
    WB::Router->new(
        
        env => shift,
        template_engine => 'HTML::Template',
        
        #db_dsn      => 'DBI:mysql:database=test;host=127.0.0.1',
        #db_login    => 'test',
        #db_password => 'test',
        
        secret => '0IkJmbamAN@cboU&hHJxtruU1cI!5Lf4',
        
        vboxmanage => new VBoxManage,
        
    )->dispatch(
        
        root 'Page::index',
        
        
        get(  '/auth'        => 'Auth::index' ),
        post( '/auth/login'  => 'Auth::login' ),
        get(  '/auth/logout' => 'Auth::logout' ),
        
        
        
    );
};


=head1        
    
    example call:
    ----------------------------------------------------------------------------
    ->dispatch(
        
        root 'Page::index',
        resource 'photo',
        
        get( '/auth'        => 'Auth::index' ),
        post( '/auth/login' => 'Auth::login' ),
        get( '/auth/logout' => 'Auth::logout' ),
        
        scope('/admin' => [
            resource 'user',
            get( '/profile' => 'Page::profile' ),
            get( '/api'     => 'Admin::Page::api' ),
            
            scope('/news' => [
                get( '/info' => 'News::info' ),
                get( '/show' => 'News::show' ),
                
                resource 'article',
            ]),
        ]),
    );
    
=cut        
