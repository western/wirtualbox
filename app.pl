
use strict;
use warnings;

use utf8;

use lib 'lib';
use WB::Router qw(:def);





my $app = sub {
    
    WB::Router->new(
        
        env => shift,
        template_engine => 'HTML::Template',
        secret => '0IkJmbamAN@cboU&hHJxtruU1cI!5Lf4',
        
    )->dispatch(
        
        root 'Page::index',
        resource 'photo',
        
        get {'/vector/info/:option/:option2' => 'Vector::Info::hard'},
        get {'/vector/info/:option' => 'Vector::Info::simple'},
        get {'/vector/info' => 'Vector::Info::index'},
        
        post {'/auth/login' => 'Auth::login'},
        get {'/auth' => 'Auth::index'},
    );
};
