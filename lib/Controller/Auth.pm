
package Controller::Auth;

use WB::Util qw(dumper main_template);


#main_template 'main2';


sub index{
    my($o, $r, $args) = @_;
    
    #$res->body(__PACKAGE__." index call");
    #$res->body(dumper $args);
=head1    
    $res->body(q~
                <form method=post action='/auth/login' >
                    <input type="hidden" name="hid1" value="val1">
                    <input type="hidden" name="hid2" value="val2">
                    <input type="hidden" name="hid2" value="val3">
                    <input type="submit" value="!Clickme">
                </form>
                
                <hr>
                
                <form method=post action='/auth/login' enctype="multipart/form-data">
                    <input type="hidden" name="hid1" value="val1">
                    <input type="hidden" name="hid2" value="val2">
                    <input type="hidden" name="hid2" value="val3">
                    <input type="file" name="file1" >
                    <input type="file" name="file2" >
                    <input type="submit" value="!Clickme 2">
                </form>
                
                <br><a href="?n1=value1&n1=value11&n2=value2">!Clickme</a><br>
            ~,
    );
=cut    
    #warn __PACKAGE__." index call";
    #warn "dumper ".dumper(\@_);
}

sub login{
    my($o, $r, $args) = @_;
    
    #$res->body(__PACKAGE__." login call");
    #$res->body(dumper $args);
    
    #warn __PACKAGE__." index call";
    #warn "dumper ".dumper(\@_);
}

1;
