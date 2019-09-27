# Thing
##### Thing is a yet another [small] [editable] [mobility] perl web [PSGI] framework with [predeclared behaviour]
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
* get repository
* run "make" command
* and enjoy
## Routing
System support follow requests on low level:
* get - ``` get( '/path/to/' => 'Package::Full::Name::and_his_action' ) ```
* post - ``` post( '/path/to/' => 'Package::Full::Name::and_his_action' ) ```
### Special
* root - declare action for root "/" request
* resource
* scope - combine some sources with location
### Resource
Resource is a automatic generator for all source methods REST support
Example, resource 'namething' make:
* GET /namething/new for ```Namething::new``` sub
* POST /namething - ```Namething::create```
* GET /namething/:id/edit - ```Namething::edit```
* GET /namething/:id/del - ```Namething::del```
* POST /namething/:id - ```Namething::update```
* GET /namething/:id - ```Namething::show```
* GET /namething/ - ```Namething::index```

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
* get /admin - ```/lib/Admin/Page.pm``` - 'Admin::Page::index' if you set "several package names and one action" - path is ```/lib/Full/Package/Name.pm```
* get /admin/vm/:uuid - 'Admin::Vm::show' with param 'uuid' ( $args->{uuid} )
* get /admin/vm/new - 'Admin::Vm::new'
* resource 'photo' - make several actions. See Resource next.
* /admin/inside/ + /doc/ resource
