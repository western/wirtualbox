
package WB::Model;

use utf8;
use WB::Util qw(:def);

use Cwd;


sub new {
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        %arg
    };
    
    $self = bless $self, $class;
    
    $self->_prepare_model();
    
    $self;
}

sub _prepare_model {
    my $self = shift;
    my $cwd  = getcwd();
    $cwd .= '/lib/Model';
    
    opendir(my $dh, $cwd) or die "Can't opendir $cwd: $!";
    my @models = grep { /\.pm$/ && -f "$cwd/$_" } readdir($dh);
    closedir $dh;
    
    
    
    for my $m ( @models ) {
        
        warn $cwd.'/'.$m;
        require $cwd.'/'.$m;
        
        my @pack = split(m!/!, $m);
        my $name = pop @pack;
        $name =~ s!\.pm$!!;
        my $pack = 'Model::'.$name;
        
        my $cl = $self->{models}->{$name} = $pack->new(
            env => $self->{env},
            db  => $self->{db},
        );
        
        # get fields
        $cl->_set_db( $self->{db} );
        $cl->_init();
        
        no strict 'refs';
        *{"WB::Model::${name}"} = sub{ shift->get_model($name) };
        use strict 'refs';
        
    }
    
}

sub get_model {
    my $self = shift;
    my $name = shift;
    
    $self->{models}->{$name} or die "not found model [$name]";
}

sub db {
    shift->{db};
}

1;
