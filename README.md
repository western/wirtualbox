# WB (temporary work name)
##### WB is a yet another [small] [editable] [mobility] perl web [PSGI] framework with [predeclared behaviour]
##### Inspired by [Rambler X-Ware 3] [ruby rails] [perl Catalyst] [perl Mojo]
##### Small - all current version code contained in several packages:
* DB
* File - Class support for upload files
* Request
* Response
* Router - Main work class
* Template
* Util
##### Editable - get any version of code, integrate and gain full control
##### Mobility - do not any install
##### PSGI - Perl Web Server Gateway Interface specification
##### Predeclared behaviour - some behaviours dictated from framework
## Fast start
* get repository `https://github.com/western/wirtualbox`
* run `make` command - developer environment start for default 8090 port
* run `make run` - start daemon for default 8090 port
* run `make kill` - kill daemon
## Routing
System support follow requests on low level:
* ` get( '/path/to/' => 'Package::Full::Name::and_his_action' ) `
* ` post( '/path/to/' => 'Package::Full::Name::and_his_action' ) `
### Special
* root - declare action for `root "/"` request
* resource
* scope - combine some sources with location
### Resource
Resource is a automatic generator for all source methods REST support
Example, resource 'namething' make:
* GET `/namething/new` for `Namething::new` sub
* POST `/namething` - `Namething::create`
* GET `/namething/:id/edit` - ```Namething::edit```
* GET `/namething/:id/del` - ```Namething::del```
* POST `/namething/:id` - ```Namething::update```
* GET `/namething/:id` - ```Namething::show```
* GET `/namething/` - ```Namething::index```

##### Example 1: simple source file with root and /auth requests
```perl
# app.pl code source

use lib 'lib';
use WB::Router qw(:def); # export some functions

my $app = sub {
    
    WB::Router->new(
        env => shift,
        template_engine => 'HTML::Template',
        secret => '0IkJmbamAN@cboU&hHJxtruU1cI!5Lf4',
    )->dispatch(
        root 'Page::index',
        get(  '/auth' => 'Auth::index' ),
    );
};

```
###### This code generate next two services:
* / - will work with ```/lib/Controller/Page.pm```
* /auth - with ```/lib/Controller/Auth.pm```

##### Example 2: routing with extended options
```perl
# app.pl code source

use lib 'lib';
use WB::Router qw(:def); # export some functions

my $app = sub {
    
    WB::Router->new(
        env => shift,
        template_engine => 'HTML::Template',
        secret => '0IkJmbamAN@cboU&hHJxtruU1cI!5Lf4',
    )->dispatch(
        root 'Page::index',
        
        get(  '/auth'        => 'Auth::index' ),
        post( '/auth/login'  => 'Auth::login' ),
        get(  '/auth/logout' => 'Auth::logout' ),
        
        get('/admin' => 'Admin::Page::index'),
        
        scope('/admin' => [
            
            get('/vm/:uuid' => 'Admin::Vm::show'),
            get('/vm/new' => 'Admin::Vm::new'),
            
            resource 'photo',
            
            scope('/admin/inside' => [
                
                resource 'doc',
            ]),
        ]),    
    );
};

```
###### Code support for:
* get / - will work with ```/lib/Controller/Page.pm```
* get /auth - ```/lib/Controller/Auth.pm```
* post /auth/login
* get /auth/logout - 'Auth::logout' if you declare "one package name and one action" - path is /lib/Controller/Auth
* get /admin - ```/lib/Admin/Page.pm``` - 'Admin::Page::index' if you set "several package names Admin::Page:: and one action" - path is ```/lib/Admin/Page.pm```
* get /admin/vm/:uuid - 'Admin::Vm::show' with param 'uuid' ( $args->{uuid} )
* get /admin/vm/new - 'Admin::Vm::new'
* resource 'photo' - make several actions. See Resource next.
* /admin/inside/ + /doc/ resource
## Controller
Common code of controller:
```perl
# file /lib/Controller/Photo.pm
package Controller::Photo;

use utf8;
use WB::Util qw(:def);

1;
```
Full controller source:
```perl
# file /lib/Controller/Photo.pm
package Controller::Photo;

use utf8;
use WB::Util qw(:def);

required 'App::auth_required'; # Controller::App with action "auth_required"
template_layout 'admin';       # main template

sub new {
    my($self, $r, $args) = @_;
}

sub create {
    my($self, $r, $args) = @_;
}

sub edit {
    my($self, $r, $args) = @_;
}

sub del {
    my($self, $r, $args) = @_;
}

sub update {
    my($self, $r, $args) = @_;
}

sub show {
    my($self, $r, $args) = @_;
}

sub index {
    my($self, $r, $args) = @_;
}

1;
```

### Action arguments

app.pl
```perl

get('/photo/some/:uuid' => 'Photo::some_change'),

```

Controller:
```perl
# file /lib/Controller/Photo.pm
package Controller::Photo;

use utf8;
use WB::Util qw(:def);

sub some_change {
    my($self, $r, $args) = @_;
    
    warn $args->{uuid};
    
}
```

### Templates

By default you can create only package empty. And templates will be use.

```perl
# file /lib/Controller/Photo.pm
package Controller::Photo;

use utf8;
use WB::Util qw(:def);

sub some_change {
    my($self, $r, $args) = @_;
    
    # by default, system get find /template/Controller/Photo/some_change.html
    # and 'main' layout
    $r->response->template_args(
        head_title => 'some title of page',
    );
}
```

Controller:
```perl
# file /lib/Controller/Photo.pm
package Controller::Photo;

use utf8;
use WB::Util qw(:def);

template_layout 'admin';  # main template
#template_layout 'none';  # continue without main template
# if you do not set template_layout, system set by default 'main'

# define   /photo/some/:uuid
# and call /photo/some/111-222-333
sub some_change {
    my($self, $r, $args) = @_;
    
    if ( $args->{uuid} ) {
        
        # by default, system get find /template/Controller/Photo/some_change.html
        $r->response->template_args(
            list       => [1, 2, 3],
            uuid       => $args->{uuid},
            head_title => 'some title of page',
        );
        
        # but you can change template file
        $r->response->template_file(
            'template_file', 'template_layout'
        );
    }
}
```

Send json data:
```perl
# file /lib/Controller/Photo.pm
package Controller::Photo;

use utf8;
use WB::Util qw(:def);

sub some_change {
    my($self, $r, $args) = @_;
    
    if ( $args->{uuid} ) {
        
        # send content-type: application/json;charset=utf-8
        # and json data
        $r->response->json({
            name1 => 'xtra',
            val2  => 95,
        });
    }
}
```
## Model
### Model example
```perl

package Model::Article;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'articles' );

__PACKAGE__->config( define_type => {
    'articles.body'  => 'Wysiwyg',
    'articles.title' => 'Edit',
});

__PACKAGE__->belong_to( user_id => 'users.id' );
__PACKAGE__->has_many( id => 'comments.article_id' );
1;

```
```perl

package Model::User;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'users' );

1;

```
### Model call
```perl
sub index {
    my($self, $r, $args) = @_;
    
    # get database handle
    $r->model->db;
    # or
    $r->model->Article->db;
    # select * from articles
    $r->model->Article->list;
    # get value registered from first row
    $r->model->Article->list->[0]->{registered}->value;
    
    # $r->model->Article->join( 'users' )->list->[0];
    # $r->model->Article->join( 'left users' )->list->[0];
    # $r->model->Article->join( 'left users' => 'articles.user_id = users.xx' )->list->[0];
    # $r->model->Article->join( 'comments' )->list->[0];
    # $r->model->Article->join( 'left comments' )->list->[0];
    
    # $r->model->Article->join( 'users' )->list()->[0];
    # $r->model->Article->join( 'users' )->list->[0];
    # $r->model->Article->join( 'users' )->list( -flat => 1 )->[0];
    # $r->model->Article->join( 'users' )->list( -data => 1 )->[0];
    # $r->model->Article->join( 'users' )->list( -data => 1 );
}
```

## WB Type
### WB Type simple

```perl
package WB::Type::Int;

use base WB::Type::Basement;

1;

```

### WB Type extend

```perl

package WB::Type::Wysiwyg;

use base WB::Type::Text;

sub value {
    my $self  = shift;
    my $value = shift;
    
    $self->{value} = $value if ( defined $value );
    
    '[['.$self->{value}.']]';
}

1;

```
