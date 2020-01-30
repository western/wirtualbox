
use Test::More tests => 1;


use WB::Router qw(:def);
use WB::Util qw(dumper);



my $router = WB::Router->new(
    env             => get_env(),
    template_engine => 'HTML::Template',
    secret          => '0IkJmbamAN@cboU&hHJxtruU1cI!5Lf4',
);

$router->dispatch(
    
    root 'Page::index',
    
    get(  '/auth'        => 'Auth::index' ),
    post( '/auth/login'  => 'Auth::login' ),
    get(  '/auth/logout' => 'Auth::logout' ),
    
    get('/admin' => 'Admin::Page::index'),
    
    scope('/admin' => [
        
        get('/vm/:uuid' => 'Admin::Vm::show'),
        get('/vm/new'   => 'Admin::Vm::new'),
        
        resource 'photo',
        
        scope('/admin/inside' => [
            
            resource 'doc',
        ]),
        
        
    ]),
);


die array_chk( $router->{list},
    action          => "Page::index",
    method          => "GET",
    origin          => "root",
    path            => "/",
    template_file   => qr!/template/Controller/Page/index.html$!,
    template_layout => qr!/template/main.html$!,
);

#ok( $res->[0]->{user}->{login} eq 'login1', 'test 1' );
#ok( 1, 'test 1' );

=head2 array_chk
    
    array_chk( $list,
        name1 => val1,
        name2 => val2,
    )
    
=cut
sub array_chk {
    my $list = shift;
    my %arg = @_;
    
    for my $el ( @$list ) {
        
        my $is_yes = 1;
        for my $key ( keys %arg ) {
            
            if( $arg{$key} && ref($arg{$key}) && ref($arg{$key}) eq 'Regexp' && $el->{$key} !~ $arg{$key} ) {
                $is_yes = 0;
            }
            if( $arg{$key} && !ref($arg{$key}) && "$el->{$key}" ne "$arg{$key}" ) {
                $is_yes = 0;
            }
        }
        
        return 1 if ( $is_yes );
    }
    
    0;
}

sub get_env {
    return {
        "HTTP_ACCEPT" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "HTTP_ACCEPT_ENCODING" => "gzip, deflate",
        "HTTP_ACCEPT_LANGUAGE" => "en-US,en;q=0.5",
        "HTTP_CACHE_CONTROL" => "max-age=0",
        "HTTP_CONNECTION" => "keep-alive",
        #"HTTP_COOKIE" => "auth=",
        'HTTP_COOKIE' => 'auth=53616c7465645f5ffa213b16cd33399eadfdcf99ba69ffd910f2e85d8c694a8cc4fe16cd4ac5a06d57b7b1906afe32aad19f4296b32f6300299ccb1c3eb9a778',
        "HTTP_HOST" => "localhost:8090",
        "HTTP_REFERER" => "http://localhost:8090/",
        "HTTP_UPGRADE_INSECURE_REQUESTS" => 1,
        "HTTP_USER_AGENT" => "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0",
        "PATH_INFO" => "/auth",
        "QUERY_STRING" => "",
        "REMOTE_ADDR" => "127.0.0.1",
        "REMOTE_PORT" => 54422,
        "REQUEST_METHOD" => "GET",
        "REQUEST_URI" => "/auth",
        "SCRIPT_NAME" => "",
        "SERVER_NAME" => "linux-783j",
        "SERVER_PORT" => 8090,
        "SERVER_PROTOCOL" => "HTTP/1.1",
        "UWSGI_ROUTER" => "http",
        "psgi.errors" => bless( do{\(my $o = undef)}, 'uwsgi::error' ),
        "psgi.input" => bless( do{\(my $o = undef)}, 'uwsgi::input' ),
        "psgi.multiprocess" => 1,
        "psgi.multithread" => 0,
        "psgi.nonblocking" => 0,
        "psgi.run_once" => 0,
        "psgi.streaming" => 1,
        "psgi.url_scheme" => "http",
        "psgi.version" => [
        1,
        1
        ],
        "psgix.cleanup" => 1,
        "psgix.cleanup.handlers" => [],
        "psgix.harakiri" => 1,
        "psgix.input.buffered" => 0,
        "psgix.logger" => sub { "DUMMY" }
    };
}
