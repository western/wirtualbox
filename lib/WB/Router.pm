
package WB::Router;

use strict;
use warnings;

use WB::Request;
use WB::Response;
use WB::DB;
use WB::Util qw(:def);

use Exporter 'import';
use Cwd;

our @EXPORT_OK = (
    qw(root resource get post scope)
);
our %EXPORT_TAGS = (def => [qw(root resource get post scope)]);


sub new {
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        template_engine => '',
        %arg,
    };
    
    bless $self, $class;
}

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
            
            scope('/news' => [
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
    
    my @list = dispatch_flat( dispatch_loop('', \@_) );
    
    for my $a ( @list ) {
        
        my @t = split(/::/, $a->{action});
        my $func = pop @t;
        my $pack = join('::', @t);
        
        my $full_path;
        if ( scalar @t > 1 ) {
            # Vector::Info::index (for Vector::Info)
            $full_path = $cwd.'/lib/'.join('/', @t).'.pm';
        } else {
            # Auth::index (for Controller::Auth)
            $pack = 'Controller::'.$pack;
            $full_path = $cwd.'/lib/Controller/'.$t[0].'.pm';
        }
        
        print_red('Package [ ', $pack, $func, ' ] => [ ', $full_path, " ] is not exists\n") unless ( -e $full_path );
        
        #warn "full_path [$full_path]";
        require $full_path;
        if ( scalar @t > 1 ) {
            $a->{template_file} = $cwd.'/template/'.join('/', @t).'/'.$func.'.html';
        } else {
            $a->{template_file} = $cwd.'/template/Controller/'.join('/', @t).'/'.$func.'.html';
        }
        
        my ($gr1, $gr2) = get_required($cwd, $full_path);
        $a->{require_sub} = sub{ $gr1->$gr2(@_) } if($gr1);
        
        my $tl = get_template_layout($full_path);
        $a->{template_layout} = $cwd.'/template/'.get_template_layout($full_path).'.html' if ( $tl ne 'none' );
        
        # ?<greet>
        # rewrite /admin/vm/:uuid/del  =>  /admin/vm/(?<:uuid>[^/]+)/del
        $a->{path} =~ s!:([^/:]+)!\(?<$1>[^/]+\)!g;
        
        $a->{action_sub} = sub{ $pack->$func(@_) };
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
    my $req = new WB::Request(
        env        => $self->{env},
        response   => $response,
        secret     => $self->{secret},
        db         => $db,
        vboxmanage => $self->{vboxmanage},
    );
    
    
    
    #die dumper \@list;
    
    
    
    my $found = 0;
    for my $a ( @list ) {
        
        my @rx_names = ( $a->{path} =~ /<(.+?)>/g );
        my $path_info = $req->path_info;
        $path_info =~ s!/$!! if ( length($path_info) > 1 ); # truncate last slash
        
        #warn "path_info [$path_info] ".dumper($a);
        
        if( $req->request_method eq $a->{method} && $path_info =~ m!^$a->{path}$! ){
            
            my %rx_args = map { $_ => $+{$_} } @rx_names;
            
            $response->template_file($a->{template_file}, $a->{template_layout});
            if ( $a->{require_sub} ) {
                $a->{action_sub}->($req, \%rx_args) if ($a->{require_sub}->($req, \%rx_args));
            } else {
                $a->{action_sub}->($req, \%rx_args);
            }
            $found = 1;
            last;
        }
    }
    
    
    
    
    $response->set404 if !$found;
    
    $response->out;
    
    
}

sub dispatch_loop {
    my $prefix = shift;
    my $arr    = shift;
    
    for my $a (@{$arr}) {
        
        if ( ref $a ne 'ARRAY' && !$prefix ){
            $prefix = $a->{prefix};
        }
        if ( ref $a ne 'ARRAY' && $prefix && $prefix ne $a->{prefix} ){
            
            $a->{prefix} = $prefix . $a->{prefix};
            
            my @pack = split('/', $a->{prefix});
            shift @pack;
            @pack = map { ucfirst $_ } @pack;
            my $prefix_pack = join('::', @pack);
            
            # replace Action for resource only
            if( $a->{action} && $a->{action} !~ /^$prefix_pack/ && $a->{origin} && $a->{origin} =~ /^resource/ ){
                $a->{action} = $prefix_pack.'::'.$a->{action};
            }
            
            $a->{path} = $prefix . $a->{path};
        }
        if ( ref $a eq 'ARRAY' ){
            $a = dispatch_loop($prefix, $a);
        }
    }
    
    $arr;
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
            $a->{prefix} = $prefix;
            $a->{path}   = $prefix . $a->{path};
        }
    }
    
    $list;
}



1;
