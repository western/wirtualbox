
package WB::Router;

use strict;
use warnings;

use WB::Request;
use WB::Response;
use WB::DB;
use WB::Model;
use WB::Util qw(:def);

use Exporter 'import';
use Cwd;

our $VERSION = '0.4';

# The sky is red, I don't understand
# Past midnight, I still see the land
# People are sayin' the woman is damned
# She makes you burn with a wave of her hand
# The city's ablaze, the town's on fire
# The woman's flames are reaching higher
# We were fools, we called her liar
# All I hear is "Burn!"

our @EXPORT_OK = (qw(
    root resource get post scope
));

our %EXPORT_TAGS = (
    def => [qw(
        root resource get post scope
    )]
);

=head2 new
    
    Constructor.
    
    Example:
    
    WB::Router->new(
        
        env => $env,
        template_engine => 'HTML::Template',
        
        db_dsn      => 'DBI:mysql:database=test;host=127.0.0.1',
        db_login    => 'test',
        db_password => 'test',
        
        secret => '0IkJmbamAN@cboU&hHJxtruU1cI!5Lf4',
        
        anothermanager => new AnotherManager,
    )
    
=cut
sub new {
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        template_engine => '',
        %arg,
    };
    
    $self = bless $self, $class;
    
    $self;
}

=head2 get_required

    Parser for get "required" pragmas.
    This pragma set function for required check.
    
    Example (code of controller):
    ----------------------------------------------------------------------------
    package Controller::Auth;
    
    use utf8;
    use WB::Util qw(:def);
    
    required 'App::auth_required';
    ----------------------------------------------------------------------------

=cut
sub get_required {
    my $cwd = shift;
    my $file = shift;
    
    open my $f, '<', $file or die $!;
    while (my $s = <$f>) {
        
        if ( $s =~ m!required(?:\s+)('|")(.+?)\1;! && $s !~ /^#/ ) {
            
            my @t = split('::', $2);
            # 'Application::auth_required'
            # 'Vector::Info::auth_required'
            my $func = pop @t;
            my $pack = join('::', @t);
            
            if ( scalar @t > 1 ) {
                # Vector::Info
                require $cwd.'/lib/'.join('/', @t).'.pm';
            } else {
                # Controller::Application
                $pack = 'Controller::'.$pack;
                require $cwd.'/lib/Controller/'.$t[0].'.pm';
            }
            
            close $f;
            return ($pack, $func);
        }
    }
    close $f;
    
    undef;
}

=head2 get_template_layout

    Parser for get "template_layout" pragma.
    This pragma set main template.
    
    Example (controller):
    ----------------------------------------------------------------------------
    package Controller::Auth;
    
    use utf8;
    use WB::Util qw(:def);
    
    template_layout 'admin'; # or 'none' without
    ----------------------------------------------------------------------------

=cut
sub get_template_layout {
    my $file = shift;
    
    open my $f, '<', $file or die $!;
    while (my $s = <$f>) {
        
        if ( $s =~ m!template_layout(?:\s+)('|")(.+?)\1;! && $s !~ /^#/ ) {
            
            close $f;
            return $2;
        }
    }
    close $f;
    
    'main';
}

=head2 dispatch
    
    Main code for route rules.
    
    arguments:
    ----------------------------------------------------------------------------
    [
        {
            origin          => 'resource photo',
            domain          => 'localhost',
            prefix          => '/admin',
            method          => 'GET|POST',
            path            => '/auth/login',
            action          => 'Auth::login',
            action_sub      => sub{},
            require_sub     => sub{},
            template_change => 'default', # default, action
            template_file   => '',
            template_layout => '',
        },
        
    ]
    
    example call:
    ----------------------------------------------------------------------------
    ->dispatch(
        
        root 'Page::index',
        resource 'photo',
        
        get( '/auth'        => 'Auth::index' ),
        post( '/auth/login' => 'Auth::login' ),
        get( '/auth/logout' => 'Auth::logout' ),
        
        scope('/admin' => [
            resource 'user',
            get( '/profile' => 'Page::profile' ),
            get( '/api'     => 'Admin::Page::api' ),
            
            scope('/admin/news' => [
                get( '/info' => 'News::info' ),
                get( '/show' => 'News::show' ),
                
                resource 'article',
            ]),
        ]),
    );
    
=cut
sub dispatch {
    my $self = shift;
    my $cwd  = getcwd();
    
    @{$self->{list}} = dispatch_flat( \@_ );
    
    
    for my $a ( @{$self->{list}} ) {
        
        my @t = split(/::/, $a->{action});
        my $func = pop @t;
        my $pack = join('::', @t);
        
        my $full_path;
        #if ( scalar @t > 1 ) {
            # Vector::Info::index (for Vector::Info)
            $full_path = $cwd.'/lib/Controller/'.join('/', @t).'.pm';
        #} else {
            # Auth::index (for Controller::Auth)
            $pack = 'Controller::'.$pack;
        #    $full_path = $cwd.'/lib/Controller/'.$t[0].'.pm';
        #}
        
        println_red('Router::', 'Package [', $pack, $func, '] => file [', $full_path, "] is not exists. See route ", dumper($a)) unless ( -e $full_path );
        
        require $full_path;
        #if ( scalar @t > 1 ) {
        #    $a->{template_file}   = $cwd.'/template/'.join('/', @t).'/'.$func.'.html';
        #} else {
            $a->{template_file}   = $cwd.'/template/Controller/'.join('/', @t).'/'.$func.'.html';
        #}
        
        my ($gr1, $gr2) = get_required($cwd, $full_path);
        $a->{require_sub} = sub{ $gr1->$gr2(@_) } if($gr1);
        
        my $tl = get_template_layout($full_path);
        $a->{template_layout} = $cwd.'/template/'.get_template_layout($full_path).'.html' if ( $tl ne 'none' );
        
        # ?<greet>
        # rewrite /admin/vm/:uuid/del  =>  /admin/vm/(?<:uuid>[^/]+)/del
        $a->{path} =~ s!:([^/:]+)!\(?<$1>[^/]+\)!g;
        
        
        if ( $pack->can($func) ) {
            
            $a->{action_sub} = sub{ $pack->$func(@_) };
            
        } else {
            
            println_yellow('Router::', 'Package [', $pack, $func, qq~] function "$func" is not exists for "$pack"~);
            
            # make dummy sub for show template without action code
            $a->{action_sub} = sub{};
        }
        
    }
    
    
    $self->{env}{root} = $cwd;
    my $db;
    if( $self->{db_dsn} ) {
        $db = WB::DB::connect(
            dsn      => $self->{db_dsn},
            login    => $self->{db_login},
            password => $self->{db_password},
        );
    };
    my $response = new WB::Response(
        env             => $self->{env},
        template_engine => $self->{template_engine},
        secret          => $self->{secret},
    );
    my $model = new WB::Model(
        env => $self->{env},
        db  => $db,
    );
    my $req = new WB::Request(
        env        => $self->{env},
        response   => $response,
        secret     => $self->{secret},
        db         => $db,
        model      => $model,
        #vboxmanage => $self->{vboxmanage},
    );
    
    
    
    
    
    
    
    my $found = 0;
    for my $a ( @{$self->{list}} ) {
        
        my @rx_names = ( $a->{path} =~ /<(.+?)>/g );
        my $path_info = $req->path_info;
        $path_info =~ s!/$!! if ( length($path_info) > 1 ); # truncate last slash
        
        
        
        if( $req->request_method eq $a->{method} && $path_info =~ m!^$a->{path}$! ){
            
            my %rx_args = map { $_ => $+{$_} } @rx_names;
            
            $response->{template_object}->{route}           = $a;
            $response->{template_object}->{template_change} = 'default';
            $response->{template_object}->{template_file}   = $a->{template_file};
            $response->{template_object}->{template_layout} = $a->{template_layout};
            
            
            if ( $a->{require_sub} ) {
                $a->{action_sub}->($req, \%rx_args) if ($a->{require_sub}->($req, \%rx_args));
            } else {
                $a->{action_sub}->($req, \%rx_args);
            }
            
            
            
            $response->template_file($a->{template_file}, $a->{template_layout}) if ( $response->{template_object}->{template_change} eq 'default' );
            
            $found = 1;
            last;
        }
    }
    
    
    
    
    $response->set404 if !$found;
    
    $response->out;
    
    
}

sub dispatch_flat {
    my $list = shift;
    my @ret;
    
    for my $a (@$list) {
        push @ret, dispatch_flat($a) if ( ref $a eq 'ARRAY' );
        push @ret, $a if ( ref $a ne 'ARRAY' );
    }
    
    @ret;
}

sub get {
    {
        method => 'GET',
        path   => $_[0],
        action => $_[1],
    };
}

sub post {
    {
        method => 'POST',
        path   => $_[0],
        action => $_[1],
    };
}

sub root($) {
    {
        origin => 'root',
        method => 'GET',
        path   => '/',
        action => $_[0],
    };
}

sub resource($) {
    my $arg  = shift;
    my $path = lc $arg;
    my $pack = ucfirst $arg;
    
    return (
        {
            origin => 'resource '.$arg,
            method => 'GET',
            path   => '/'.$path.'/new',
            action => $pack.'::new',
        },
        {
            origin => 'resource '.$arg,
            method => 'POST',
            path   => '/'.$path,
            action => $pack.'::create',
        },
        {
            origin => 'resource '.$arg,
            method => 'GET',
            path   => '/'.$path.'/:id/edit',
            action => $pack.'::edit',
        },
        {
            origin => 'resource '.$arg,
            method => 'GET',
            path   => '/'.$path.'/:id/del',
            action => $pack.'::del',
        },
        {
            origin => 'resource '.$arg,
            method => 'POST',
            path   => '/'.$path.'/:id',
            action => $pack.'::update',
        },
        {
            origin => 'resource '.$arg,
            method => 'GET',
            path   => '/'.$path.'/:id',
            action => $pack.'::show',
        },
        {
            origin => 'resource '.$arg,
            method => 'GET',
            path   => '/'.$path,
            action => $pack.'::index',
        },
    );
}

sub scope {
    my $prefix = shift;
    my $list   = shift;
    
    for my $a (@{$list}){
        
        if (ref $a eq 'HASH'){
            if ( $a->{origin} =~ /^resource/ ){
                my @prefix = split(m!/!, $prefix);
                shift @prefix;
                @prefix = map { ucfirst $_ } @prefix;
                
                $a->{action} = join('::', @prefix) . '::' . $a->{action};
            }
            $a->{prefix} = $prefix;
            $a->{path}   = $prefix . $a->{path};
        }
    }
    
    $list;
}



1;
