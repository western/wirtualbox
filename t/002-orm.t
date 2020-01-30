

use Test::More tests => 1;
use Cwd;

use lib 'lib';
use WB::Util qw(dumper);
use WB::DB;
use WB::Model;




my $env = {root => getcwd()};
my $db = WB::DB::connect(
    dsn      => 'DBI:mysql:database=test;host=127.0.0.1',
    login    => 'test',
    password => 'test',
);
my $model = new WB::Model(
    env => $env,
    db  => $db,
);



my $a = $model->Article->limit(1)->list->[0];
#die dumper $a;

ok( 1, 'test 1' );
