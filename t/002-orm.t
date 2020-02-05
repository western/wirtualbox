

use Test::More tests => 7;
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

$row = $model->Article->where(id=>2)->limit(1)->list( -data=>1 )->[0];
ok( $row->{title} eq 'title2', 'test 4' );

$row = $model->Article->where(id=>2)->limit(1)->list( -data=>1, -json=>1 )->[0];
ok( $row && $row =~ /body2/ && $row =~ /title2/, 'test 5' );

$row = $model->Article->where('article.id'=>1)->join('uploadfile')->limit(1)->list( -data=>1 )->[0];
ok( $row && $row->{'ph.filename'}, 'test 6 (Alias test)' );

$row = $model->Article->count;
ok( $row, 'test 7' );



