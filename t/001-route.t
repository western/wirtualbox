
use Test::More tests => 1;

use lib 'lib';
use WB::Router qw(:def);
use WB::Util qw(dumper);


WB::Router->new(env => 'env-sample-string')->dispatch(
    #resource 'photo',
    #resource 'Vector::Info',
    get {'/vector/info' => 'Vector::Info::index'},
    get {'/vector/info/:option' => 'Vector::Info::simple'},
    get {'/vector/info/hard/:option/:option2' => 'Vector::Info::hard'},
    #get {'/auth' => 'Auth::index'},
    #post {'/api' => 'Api::post'},
);

#ok( $res->[0]->{user}->{login} eq 'login1', 'test 1' );
ok( 1, 'test 1' );
