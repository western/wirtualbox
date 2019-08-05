
package Controller::Photo;

use WB::Util qw(dumper);

=head1
['get', '/'.$path, $pack.'::index'],
['get', '/'.$path.'/new', $pack.'::new'],
['post', '/'.$path, $pack.'::create'],
['get', '/'.$path.'/:id', $pack.'::show'],
['get', '/'.$path.'/:id/edit', $pack.'::edit'],
['post', '/'.$path.'/:id', $pack.'::update'],
['get', '/'.$path.'/:id/del', $pack.'::destroy'],
=cut

sub index{
    my($o, $req, $res, $args) = @_;
    
    #$res->body(__PACKAGE__." index call");
    #$res->body(dumper $args);
    
    $res->template_args(
        name => 'Вася',
        surname => 'Quadrant',
    );
    
}

sub new{
    my($o, $req, $res, $args) = @_;
    
    $res->body(__PACKAGE__." new call");
    $res->body(dumper $args);
}

sub create{
    my($o, $req, $res, $args) = @_;
    
    $res->body(__PACKAGE__." create call");
    $res->body(dumper $args);
}

sub show{
    my($o, $req, $res, $args) = @_;
    
    $res->body(__PACKAGE__." show call");
    $res->body(dumper $args);
}

sub edit{
    my($o, $req, $res, $args) = @_;
    
    $res->body(__PACKAGE__." edit call");
    $res->body(dumper $args);
}

sub update{
    my($o, $req, $res, $args) = @_;
    
    $res->body(__PACKAGE__." update call");
    $res->body(dumper $args);
}

sub destroy{
    my($o, $req, $res, $args) = @_;
    
    $res->body(__PACKAGE__." destroy call");
    $res->body(dumper $args);
}

1;
