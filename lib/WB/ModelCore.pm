
package WB::ModelCore;

use strict;
use warnings;
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

sub _sql_compile {
    my $self = shift;
    my $sql = "select ";
    
    if ( $self->{fields} ) {
        for my $f ( @{$self->{fields}} ) {
            $sql .= $f->{name_full}.', ';
        }
        $sql =~ s!, $!!;
        $sql .= "\n";
    } else {
        $sql .= "* \n";
    }
    
    $sql .= "from $self->{table_name} \n";
    
    for my $j ( @{$self->{join}} ) {
        # prefix contain: left, inner, outer
        $sql .= $j->{prefix}.' ' if ( $j->{prefix} );
        $sql .= 'join '.$j->{table}."\n";
        $sql .= ' on '.$j->{on}."\n";
    }
    
    $sql .= "\n";
    
    if ( $self->{where} ) {
        $sql .= 'where '.join(' and ', @{$self->{where}});
        $sql .= "\n";
    }
    
    
    
    $sql .= ($self->{orderby} && scalar @{$self->{orderby}}) ?
        "order by ".join(', ', @{$self->{orderby}}) : "order by ".$self->{table_name}.'.'.$self->{primary_name}." asc";
    
    warn "_sql_compile= ".$sql;
    
    $sql;
}

sub select {
    my $self = shift;
    
    push @{$self->{fields}}, @_;
    
    $self;
}

=head2 join
    
    join( 'users' )
    join( 'left users' )
    join( 'left outer users' )
    join( 'users' => 'users.id = article.user_id' )
    
=cut
sub join {
    my $self = shift;
    my @table_expect = split(/\s+/, shift);
    my $on_option    = shift;
    
    # join( 'left users' )
    # join( 'left outer users' )
    # join( 'left users' => 'users.id = article.user_id' )
    if ( scalar @table_expect > 1 ) {
        
        my $table = pop @table_expect;
        
        push @{$self->{join}}, {
            prefix => join(' ', @table_expect),
            table  => $table,
            on     => $on_option ? $on_option : $self->_get_join_options( $table ),
        };
    } else {
        
        # join( 'users' )
        # join( 'users' => 'users.id = article.user_id' )
        push @{$self->{join}}, {
            prefix => 'inner',
            table  => $table_expect[0],
            on     => $on_option ? $on_option : $self->_get_join_options( $table_expect[0] ),
        };
    }
    
    warn '$self->{join}= '.dumper $self->{join};
    
    
    $self;
}

sub _get_join_options {
    my $self  = shift;
    my $table = shift;
    
    
    for my $el ( @{$self->{belong_to}} ) {
        my @t = split(/\./, $el->[1]);
        if( $table eq $t[0] ){
            return $self->{table_name}.'.'.$el->[0].' = '.$el->[1];
        }
    }
    
    for my $el ( @{$self->{has_many}} ) {
        my @t = split(/\./, $el->[1]);
        if( $table eq $t[0] ){
            return $self->{table_name}.'.'.$el->[0].' = '.$el->[1];
        }
    }
}

sub list {
    my $self = shift;
    my %arg  = @_;
    
    my @fields = map { $_->{name} } @{$self->{fields}};
    my %fields = map { $_->{name} => $_ } @{$self->{fields}};
    
    my $list2;
    my $list = $self->db->selectall_arrayref( $self->_sql_compile );
    for my $row ( @$list ) {
        my $row2 = {};
        for ( my $i=0; $i<scalar @fields; $i++ ) {
            
            my $obj = dclone $fields{$fields[$i]};
            $obj->{value} = $row->[$i];
            
            #$row2->{$fields[$i]} = $row->[$i];
            $row2->{$fields[$i]} = $obj;
        }
        push @$list2, $row2;
    }
    
    if ( $arg{-data} ) {
        for my $row ( @$list2 ) {
            for my $key ( keys %$row ) {
                #die dumper $row;
                #warn "row->{$key}=".$row->{$key}->{value};
                $row->{$key} = $row->{$key}->value;
            }
        }
    }
    
    if ( $arg{-flat} ) {
        
        my @list3;
        
        for my $row ( @$list2 ) {
            
            my $row2 = {};
            
            for my $key ( keys %$row ) {
                
                for my $f (qw(default extra name name_full not_null primary_key type value)) {
                    $row2->{$key}->{$f} = $row->{$key}->{$f};
                }
                
            }
            push @list3, $row2;
        }
        
        @$list2 = @list3;
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
