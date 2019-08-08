
package WB::Router;

use strict;
use warnings;


use WB::Request;
use WB::Response;
use WB::DB;
use WB::Util qw(dumper);

use Exporter 'import';
use Cwd;

our @EXPORT_OK = (
    qw(root resource get post)
);
our %EXPORT_TAGS = (def => [qw(root resource get post)]);


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $o = {
        template_engine => '',
        %arg,
    };
    
    bless $o, $class;
}

sub get_required{
    my $cwd = shift;
    my $file = shift;
    
    open my $f, '<', $file or die $!;
    while(my $s = <$f>){
        
        if( $s =~ m!required(?:\s+)('|")(.+?)\1;! && $s !~ /^#/ ){
            
            my @t = split('::', $2);
            # 'Application::auth_required'
            # 'Vector::Info::auth_required'
            my $func = pop @t;
            my $pack = join('::', @t);
            
            if( scalar @t > 1 ){
                # Vector::Info
                require $cwd.'/lib/'.join('/', @t).'.pm';
            }else{
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

sub get_template_layout{
    my $file = shift;
    
    open my $f, '<', $file or die $!;
    while(my $s = <$f>){
        
        if( $s =~ m!template_layout(?:\s+)('|")(.+?)\1;! && $s !~ /^#/ ){
            
            close $f;
            return $2;
        }
    }
    close $f;
    
    'main';
}

sub dispatch{
    my $o = shift;
    my $cwd = getcwd();
    
    
    my @newa;
    my $root;
    for my $a (@_){
        
        # for resource
        if( ref $a->[0] eq 'ARRAY' ){
            push @newa, @{$a};
        }else{
            # for root extract
            if( $a->[1] eq '/' ){
                $root = $a;
            }else{
                push @newa, $a;
            }
        }
    }
    
    for my $a (@newa){
        
        # get /path Vector::Info::index (for Vector::Info)
        # get /path Auth::index (for Controller::Auth)
        my @t = split(/::/, $a->[2]);
        my $func = pop @t;
        my $pack = join('::', @t);
        
        if( scalar @t > 1 ){
            # Vector::Info::index (for Vector::Info)
            require $cwd.'/lib/'.join('/', @t).'.pm';
            $a->[4] = $cwd.'/template/'.join('/', @t).'/'.$func.'.html';
            
            my ($gr1, $gr2) = get_required($cwd, $cwd.'/lib/'.join('/', @t).'.pm');
            $a->[5] = sub{ $gr1->$gr2(@_) } if($gr1);
            
            $a->[6] = $cwd.'/template/'.get_template_layout($cwd.'/lib/'.join('/', @t).'.pm').'.html';
        }else{
            # Auth::index (for Controller::Auth)
            $pack = 'Controller::'.$pack;
            require $cwd.'/lib/Controller/'.$t[0].'.pm';
            $a->[4] = $cwd.'/template/Controller/'.$t[0].'/'.$func.'.html';
            
            my ($gr1, $gr2) = get_required($cwd, $cwd.'/lib/Controller/'.$t[0].'.pm');
            $a->[5] = sub{ $gr1->$gr2(@_) } if($gr1);
            
            $a->[6] = $cwd.'/template/'.get_template_layout($cwd.'/lib/Controller/'.$t[0].'.pm').'.html';
        }
        
        #warn "pack=[$pack] func=[$func]";
        
        # ?<greet>
        $a->[1] =~ s!:([^/:]+)!\(?<$1>[^/]+\)!g;
        
        $a->[3] = sub{ $pack->$func(@_) };
    }
    
    $o->{env}{root} = $cwd;
    my $db;
    if( $o->{db_dsn} ){
        $db = WB::DB::connect(
            dsn => $o->{db_dsn},
            login => $o->{db_login},
            password => $o->{db_password},
        );
    }
    my $response = new WB::Response(env=>$o->{env}, template_engine=>$o->{template_engine}, secret=>$o->{secret});
    my $req = new WB::Request(env=>$o->{env}, response=>$response, secret=>$o->{secret}, db=>$db, vboxmanage=>$o->{vboxmanage});
    
    
    my $found = 0;
    if( $req->request_method eq 'GET' && $req->path_info eq '/' ){
        
        my @t = split(/::/, $root->[2]);
        my $func = pop @t;
        my $pack = join('::', @t);
        
        if( scalar @t > 1 ){
            # Vector::Info::index (for Vector::Info)
            require $cwd.'/lib/'.join('/', @t).'.pm';
            $root->[4] = $cwd.'/template/'.join('/', @t).'/'.$func.'.html';
            
            my ($gr1, $gr2) = get_required($cwd, $cwd.'/lib/'.join('/', @t).'.pm');
            $root->[5] = sub{ $gr1->$gr2(@_) } if($gr1);
            
            $root->[6] = $cwd.'/template/'.get_template_layout($cwd.'/lib/'.join('/', @t).'.pm').'.html';
        }else{
            # Auth::index (for Controller::Auth)
            $pack = 'Controller::'.$pack;
            require $cwd.'/lib/Controller/'.$t[0].'.pm';
            $root->[4] = $cwd.'/template/Controller/'.$t[0].'/'.$func.'.html';
            
            my ($gr1, $gr2) = get_required($cwd, $cwd.'/lib/Controller/'.$t[0].'.pm');
            $root->[5] = sub{ $gr1->$gr2(@_) } if($gr1);
            
            $root->[6] = $cwd.'/template/'.get_template_layout($cwd.'/lib/Controller/'.$t[0].'.pm').'.html';
        }
        
        $response->template_file($root->[4], $root->[6]);
        if($root->[5]){
            $pack->$func($req) if ($root->[5]($req));
        }else{
            $pack->$func($req);
        }
        $found = 1;
        
    }else{
        
        for my $a (@newa){
            
            my @rx_names = ( $a->[1] =~ /<(.+?)>/g );
            my $path_info = $req->path_info;
            $path_info =~ s!/$!!g; # truncate last slash
            
            if( $req->request_method eq $a->[0] && $path_info =~ /^$a->[1]$/ ){
                
                #warn '$req->path_info='.$req->path_info.' $a->[1]='.$a->[1];
                
                my %rx_args = map { $_ => $+{$_} } @rx_names;
                
                $response->template_file($a->[4], $a->[6]);
                if( $a->[5] ){
                    $a->[3]->($req, \%rx_args) if ($a->[5]->($req, \%rx_args));
                }else{
                    $a->[3]->($req, \%rx_args);
                }
                $found = 1;
                last;
            }
        }
    }
    
    #warn dumper \@newa;
    
    $response->set404 if !$found;
    
    $response->out;
}

sub root($){
    ['GET', '/', ucfirst $_[0]];
}

sub resource($){
    my $arg = shift;
    my $path = lc $arg;
    my $pack = ucfirst $arg;
    
    [
        ['GET', '/'.$path.'/new', $pack.'::new'],
        ['POST', '/'.$path, $pack.'::create'],
        ['GET', '/'.$path.'/:id/edit', $pack.'::edit'],
        ['GET', '/'.$path.'/:id/del', $pack.'::destroy'],
        ['POST', '/'.$path.'/:id', $pack.'::update'],
        ['GET', '/'.$path.'/:id', $pack.'::show'],
        ['GET', '/'.$path, $pack.'::index'],
    ];
}

sub get($){
    ['GET', keys %{$_[0]}, values %{$_[0]}];
}

sub post($){
    ['POST', keys %{$_[0]}, values %{$_[0]}];
}



1;
