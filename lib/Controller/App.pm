
package Controller::App;

use utf8;
use WB::Util qw(:def);


sub auth_required {
    my($self, $r, $args) = @_;
    
    if ( my $auth = $r->cookie('auth') ) {
        return 1;
    } else {
        $r->response->set403();
    }
    
    0;
}

sub auth_required_json {
    my($self, $r, $args) = @_;
    
    if ( my $auth = $r->cookie('auth') ) {
        return 1;
    } else {
        $r->response->json(
            code => 'err',
            msg  => 'auth required',
        );
    }
    
    0;
}

1;
