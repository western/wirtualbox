
package Controller::Page;

use WB::Util qw(dumper);


sub index{
    my($o, $r, $args) = @_;
    
    #die 999;
    #warn dumper $req->{env};
    
    my $val = {
        name => 'Вася',
        surname => 'Тубареткин',
        include => [1,2,3],
    };
    
    #warn 'get n_cookie=', dumper $r->cookie('n_cookie', decrypt => 1, json => 1);
    warn 'get n_cookie=', $r->cookie('n_cookie', decrypt => 1, json => 1)->{surname};
    
    $r->response->cookie(name => 'n_cookie', value => $val, expires => '+24h', crypt => 1, json => 1);
    warn dumper $r->response->{cookie};
    
    #$res->body(__PACKAGE__." index call");
    #$res->body(dumper $args);
}



1;
