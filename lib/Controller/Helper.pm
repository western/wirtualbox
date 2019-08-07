
package Controller::Helper;

use utf8;
use WB::Util qw(:def);


sub is_auth{
    my($r, $args) = @_;
    
    if( my $auth = $r->cookie('auth', json => 1, decrypt => 1) ){
        if( $auth->{login} && $auth->{password} ){
            return 1;
        }
    }
    
    0;
}

1;
