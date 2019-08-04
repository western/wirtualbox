
package WB::Router;

use strict;
use warnings;


use WB::Request;
use WB::Response;
use WB::Util qw(dumper);

use Exporter 'import';
use Cwd;

our @EXPORT_OK = (
    qw(resource get post)
);
our %EXPORT_TAGS = (def => [qw(resource get post)]);


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $o = {
        %arg,
    };
    
    bless $o, $class;
}

sub dispatch{
    my $o = shift;
    my $cwd = getcwd();
    
    #warn dumper \@_;
    
    for my $a (@_){
        
        # remove last slash
        #$a->[0] =~ s!/$!!;
        
        # resource 'photo'
        if($a->[0] eq 'resource'){
            
            my @t = split(/::/, $a->[2]);
            my $func = 'index';
            my $pack = join('::', @t);
            
            if( scalar @t > 1 ){
                require $cwd.'/lib/'.join('/', @t).'.pm';
            }else{
                $pack = 'Controller::'.$pack;
                require $cwd.'/lib/Controller/'.$t[0].'.pm';
            }
            
            warn "pack=[$pack] func=[$func]";
            
            $a->[3] = sub{ $pack->$func(@_) };
        }
        
        # get /path Vector::Info::index (for Vector::Info)
        # get /path Auth::index (for Controller::Auth)
        if( $a->[0] eq 'get' || $a->[0] eq 'post' ){
            
            my @t = split(/::/, $a->[2]);
            my $func = pop @t;
            my $pack = join('::', @t);
            
            if( scalar @t > 1 ){
                # Vector::Info::index (for Vector::Info)
                require $cwd.'/lib/'.join('/', @t).'.pm';
            }else{
                # Auth::index (for Controller::Auth)
                $pack = 'Controller::'.$pack;
                require $cwd.'/lib/Controller/'.$t[0].'.pm';
            }
            
            warn "pack=[$pack] func=[$func]";
            
            # ?<greet>
            $a->[1] =~ s!:([^/:]+)!\(?<$1>[^/]+\)!g;
            
            $a->[3] = sub{ $pack->$func(@_) };
        }
    }
    
    my $req = new WB::Request(env=>$o->{env});
    my $response = new WB::Response(env=>$o->{env});
    
    for my $a (@_){
        
        my @rx_names = ( $a->[1] =~ /<(.+?)>/g );
        
        if( $req->request_method eq uc $a->[0] && $req->path_info =~ /$a->[1]/ ){
            
            my %rx_args = map { $_ => $+{$_} } @rx_names;
            
            $a->[3]->($req, $response, \%rx_args);
            last;
        }
    }
    
    #$_[3][3]->();
    #warn dumper \@_;
    #warn '$response='.dumper($response);
    
    $response->out;
}

sub resource($){
    ['resource', '/'.lc $_[0], ucfirst $_[0]];
}

sub get($){
    ['get', keys %{$_[0]}, values %{$_[0]}];
}

sub post($){
    ['post', keys %{$_[0]}, values %{$_[0]}];
}


1;
