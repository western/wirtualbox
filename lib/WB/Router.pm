
package WB::Router;

use strict;
use warnings;


use WB::Request;
use WB::Response;
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
        }else{
            # Auth::index (for Controller::Auth)
            $pack = 'Controller::'.$pack;
            require $cwd.'/lib/Controller/'.$t[0].'.pm';
            $a->[4] = $cwd.'/template/Controller/'.$t[0].'/'.$func.'.html';
        }
        
        #warn "pack=[$pack] func=[$func]";
        
        # ?<greet>
        $a->[1] =~ s!:([^/:]+)!\(?<$1>[^/]+\)!g;
        
        $a->[3] = sub{ $pack->$func(@_) };
    }
    
    $o->{env}{root} = $cwd;
    my $response = new WB::Response(env=>$o->{env}, template_engine=>$o->{template_engine}, secret=>$o->{secret});
    my $req = new WB::Request(env=>$o->{env}, response=>$response, secret=>$o->{secret});
    
    
    my $found = 0;
    if( $req->request_method eq 'GET' && $req->path_info eq '/' ){
        
        my @t = split(/::/, $root->[2]);
        my $func = pop @t;
        my $pack = join('::', @t);
        my $template_file = '';
        
        if( scalar @t > 1 ){
            # Vector::Info::index (for Vector::Info)
            require $cwd.'/lib/'.join('/', @t).'.pm';
            $template_file = $cwd.'/template/'.join('/', @t).'/'.$func.'.html';
        }else{
            # Auth::index (for Controller::Auth)
            $pack = 'Controller::'.$pack;
            require $cwd.'/lib/Controller/'.$t[0].'.pm';
            $template_file = $cwd.'/template/Controller/'.$t[0].'/'.$func.'.html';
        }
        
        $response->template_file($template_file);
        $pack->$func($req);
        $found = 1;
        
    }else{
        
        for my $a (@newa){
            
            my @rx_names = ( $a->[1] =~ /<(.+?)>/g );
            
            if( $req->request_method eq $a->[0] && $req->path_info =~ /^$a->[1]$/ ){
                
                #warn '$req->path_info='.$req->path_info.' $a->[1]='.$a->[1];
                
                my %rx_args = map { $_ => $+{$_} } @rx_names;
                
                $response->template_file($a->[4]);
                $a->[3]->($req, \%rx_args);
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
