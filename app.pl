
use strict;
use warnings;

use utf8;

use lib 'lib';
use WB::Router qw(:def);





my $app = sub {
    
    WB::Router->new(
        
        env => shift,
        template_engine => 'HTML::Template',
        
        #db_dsn => 'DBI:mysql:database=test;host=127.0.0.1',
        #db_login => 'test',
        #db_password => 'test',
        
        secret => '0IkJmbamAN@cboU&hHJxtruU1cI!5Lf4',
        
    )->dispatch(
        
        root 'Page::index',
        #resource 'photo',
        
        get {'/auth' => 'Auth::index'},
        post {'/auth/login' => 'Auth::login'},
        get {'/auth/logout' => 'Auth::logout'},
        
        get {'/admin' => 'Admin::Page::index'},
        get {'/admin/order' => 'Admin::Order::index'},
        get {'/admin/order/list' => 'Admin::Order::list'},
    );
};
