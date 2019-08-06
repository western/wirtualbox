
package Controller::Api;


use utf8;
use WB::Util qw(dumper required);


required 'Application::auth_required';


sub index{
    my($o, $r, $args) = @_;
    
    return $r->response->set301('/ddd/fff');
    
    $r->response->json({
        n => 'кириллица',
        pack => __PACKAGE__,
        func => 'index',
        code => 'OK',
        rr => ['DFDFDFD', 'строка символов'],
        dd => dumper(['DFDFDFD', 'строка символов'])
    });
}

sub post{
    my($o, $r, $args) = @_;
    
    $r->response->json({ pack => __PACKAGE__, func => 'post', code => 'OK' });
}

1;
