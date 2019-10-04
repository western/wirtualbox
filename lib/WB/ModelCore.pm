
package WB::ModelCore;

use utf8;
use WB::Util qw(:def);

use WB::Type::Int;
use WB::Type::Varchar;
use WB::Type::Text;
use WB::Type::Datetime;

use DBI;
use Storable qw(dclone);

# init data 
#   $WB::ModelCore->{storage}->{Package::Name}->{has_many}
#   $WB::ModelCore->{storage}->{Package::Name}->{belong_to}
our $storage = {};


sub new {
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        driver => undef,
        db     => undef,
        
        table_name   => undef,
        primary_name => undef, # primary key field name
        
        %arg
    };
    
    $self = bless $self, $class;
    
    $self;
}

sub _set_db {
    my $self = shift;
    
    $self->{driver}   = $self->{db}->{Driver}{Name};
}

sub db {
    shift->{db};
}

sub _init {
    my $self = shift;
    
    
    
    my $pack = ref $self;
    for my $k ( keys %{$WB::ModelCore::storage->{$pack}} ){
        $self->{$k} = $WB::ModelCore::storage->{$pack}->{$k};
    }
    $self->{table_name} = $WB::ModelCore::storage->{$pack}->{config}->{table_name};
    
    
    if ( $self->{driver} eq 'mysql' ) {
        
        
        $self->{fields} = [];
        
        my $fields = $self->db->selectall_arrayref( qq~desc `$self->{table_name}`~ );
        for my $a ( @$fields ) {
            
            my $type_class;
            
            $type_class = 'WB::Type::Int'      if ( $a->[1] =~ m!^int! );
            $type_class = 'WB::Type::Varchar'  if ( $a->[1] =~ m!^varchar! );
            $type_class = 'WB::Type::Text'     if ( $a->[1] =~ m!^text! );
            $type_class = 'WB::Type::Datetime' if ( $a->[1] =~ m!^datetime! );
            
            $self->{primary_name} = $a->[0] if ( $a->[3] eq 'PRI' );
            
            push @{$self->{fields}}, $type_class->new(
                name        => $a->[0],
                name_full   => '`'.$self->{table_name}.'`.`'.$a->[0].'`',
                type        => $a->[1],
                not_null    => $a->[2] eq 'YES' ? 1 : 0,
                primary_key => $a->[3] eq 'PRI' ? 1 : 0,
                default     => $a->[4],
                extra       => $a->[5],
            );
        }
        
        
    }
}

sub list {
    my $self = shift;
    
    my @fields = map { $_->{name} } @{$self->{fields}};
    my %fields = map { $_->{name} => $_ } @{$self->{fields}};
    
    
    
    my $list2;
    my $list = $self->db->selectall_arrayref( qq~select * from `$self->{table_name}` order by $self->{primary_name} asc~ );
    for my $row (@$list){
        my $row2 = {};
        for( my $i=0; $i<scalar @fields; $i++ ){
            
            my $obj = dclone $fields{$fields[$i]};
            $obj->{value} = $row->[$i];
            
            #$row2->{$fields[$i]} = $row->[$i];
            $row2->{$fields[$i]} = $obj;
        }
        push @$list2, $row2;
    }
    
    $list2;
}





sub config {
    my $package = shift;
    
    while (my($name, $value) = splice(@_, 0, 2)) {
        $WB::ModelCore::storage->{$package}->{config}->{$name} = $value;
    }
}

sub has_many {
    my $package = shift;
    
    push @{$WB::ModelCore::storage->{$package}->{has_many}}, \@_;
}

sub belong_to {
    my $package = shift;
    
    push @{$WB::ModelCore::storage->{$package}->{belong_to}}, \@_;
}

1;
