
package Controller::Auth;

use utf8;
use WB::Util qw(dumper template_layout);

template_layout 'none';


sub index {
    my($self, $r, $args) = @_;
    
    
}

sub login {
    my($self, $r, $args) = @_;
    
    my($login, $password) = $r->param('login', 'password');
    
    if ( $login && $password ) {
        
        $r->response->cookie(
            name     => 'auth',
            value    => {login => $login, password => $password},
            path     => '/',
            expires  => '+24h',
            httponly => 1,
            #secure   => 1,
            samesite => 'strict',
            
            json     => 1,
            crypt    => 1,
        );
        
        $r->response->json({
            code => 'ok',
        });
        
    } else {
        $r->response->json({
            code => 'err',
            err => ['Логин или пароль неверен'],
        });
    }
}

sub logout {
    my($self, $r, $args) = @_;
    
    $r->response->cookie(
        name     => 'auth',
        value    => '',
        path     => '/',
        expires  => '+24h',
        httponly => 1,
        #secure   => 1,
        samesite => 'strict',
    );
    $r->response->set301('/');
}

1;
