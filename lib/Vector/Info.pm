
package Vector::Info;

use WB::Util qw(dumper);


sub index{
    my($o, $req, $res, $args) = @_;
    
    $res->body(__PACKAGE__." index call");
    
    
    #warn __PACKAGE__." index call";
    #warn __PACKAGE__." res dumper ".dumper($res);
    
    #warn __PACKAGE__." dumper ".dumper(\@_);
}

sub simple{
    my($o, $req, $res, $args) = @_;
    
    $res->body(__PACKAGE__." simple call");
    $res->body(dumper $args);
    
    
    #warn __PACKAGE__." simple call";
    #warn __PACKAGE__." dumper ".dumper(\@_);
}

sub hard{
    my($o, $req, $res, $args) = @_;
    
    $res->body(__PACKAGE__." hard call");
    $res->body(dumper $args);
    
    #warn __PACKAGE__." hard call";
    #warn __PACKAGE__." dumper ".dumper(\@_);
}

1;
