
package WB::DB;

use strict;
use warnings;

use utf8;
use DBI;


sub connect{
    my %arg = @_;
    
    my $db = DBI->connect_cached($arg{dsn}, $arg{login}, $arg{password}, {RaiseError => 1}) or die DBI->errstr;
    
    $db->do('set names utf8') or die $db->errstr;
    
    $db;
}

1;
