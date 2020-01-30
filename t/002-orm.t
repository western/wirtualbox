

use Test::More tests => 3;
use Cwd;

use lib 'lib';
use WB::Util qw(:def);
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



my $row = $model->Article->limit(1)->list->[0];
my @fields = keys %$row;
ok( scalar @fields == 10, 'test 1' );


$row = $model->Article->join('user')->limit(1)->list->[0];
@fields = keys %$row;
ok( scalar @fields == 17, 'test 2' );


$row = $model->Article->join('user')->join('region')->limit(1)->list->[0];
@fields = keys %$row;
ok( scalar @fields == 19, 'test 3' );

