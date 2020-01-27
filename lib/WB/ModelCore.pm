
package WB::ModelCore;

use strict;
use warnings;
use utf8;

use DBI;
use Storable qw(dclone);
use Cwd;
use JSON::XS;

use WB::Util qw(:def);

use WB::Type::Int;
use WB::Type::Tinyint;
use WB::Type::Varchar;
use WB::Type::Enum;
use WB::Type::Text;
use WB::Type::Datetime;

# An old cowboy went riding out one dark and windy day
# Upon a ridge he rested as he went along his way
# When all at once a mighty herd of red eyed cows he saw
# A-plowing through the ragged sky and up the cloudy draw
# 
# Yippie yi ooh
# Yippie yi yay
# Ghost riders in the sky
# 
# Their brands were still on fire and their hooves were made of steel
# Their horns were black and shiny and their hot breath he could feel
# A bolt of fear went through him as they thundered through the sky
# For he saw the riders coming hard and he heard their mournful cry
# 
# Yippie yi ooh
# Yippie yi yay
# Ghost riders in the sky


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
    #println_white($pack, ' _init');
    for my $k ( keys %{$WB::ModelCore::storage->{$pack}} ){
        $self->{$k} = $WB::ModelCore::storage->{$pack}->{$k};
    }
    $self->{table_name} = $WB::ModelCore::storage->{$pack}->{config}->{table_name};
    
    
    if ( $self->{driver} eq 'mysql' ) {
        
        $self->{fields} = [];
        
        $self->_fields_from_table( $self->{table_name} );
    }
}

sub _fields_from_table {
    my $self = shift;
    my $tablename = shift;
    
    my $cwd  = getcwd();
    my $pack = ref $self;
    
    my $fields = $self->db->selectall_arrayref( qq~desc `$tablename`~ );
    for my $a ( @$fields ) {
        
        my $type_class;
        my $define_type = $WB::ModelCore::storage->{$pack}->{config}->{define_type}->{$tablename.'.'.$a->[0]};
        
        if(
            $WB::ModelCore::storage->{$pack}->{config}->{define_type} &&
            $define_type
        ){
            $type_class = 'WB::Type::'.$define_type;
            
            my $full_path = $cwd.'/lib/WB/Type/'.$define_type.'.pm';
            require $full_path;
            
        }else{
            $type_class = 'WB::Type::Int'      if ( $a->[1] =~ m!^int! );
            $type_class = 'WB::Type::Tinyint'  if ( $a->[1] =~ m!^tinyint! );
            $type_class = 'WB::Type::Varchar'  if ( $a->[1] =~ m!^varchar! );
            $type_class = 'WB::Type::Enum'     if ( $a->[1] =~ m!^enum! );
            $type_class = 'WB::Type::Text'     if ( $a->[1] =~ m!^text! );
            $type_class = 'WB::Type::Datetime' if ( $a->[1] =~ m!^datetime! );
        }
        
        # only first. at once!
        $self->{primary_name} = $a->[0] if (
            !$self->{primary_name} &&
            $a->[3] eq 'PRI'
        );
        
        push @{$self->{fields}}, $type_class->new(
            tablename   => $tablename,
            name        => $a->[0],
            name_full   => '`'.$tablename.'`.`'.$a->[0].'`',
            type        => $a->[1],
            not_null    => $a->[2] eq 'YES' ? 1 : 0,
            primary_key => $a->[3] eq 'PRI' ? 1 : 0,
            default     => $a->[4],
            extra       => $a->[5],
        );
    }
    
}

sub _sql_compile {
    my $self = shift;
    my %arg = @_;
    
    my $sql = "select ";
    
    if ( $arg{is_count} ) {
        
        $sql .= "count(*) cnt\n";
        
    } else {
        if ( $self->{fields} ) {
            for my $f ( @{$self->{fields}} ) {
                $sql .= $f->{name_full}.', ';
            }
            $sql =~ s!, $!!;
            $sql .= "\n";
        } else {
            $sql .= "* \n";
        }
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
    
    $sql .= "\n";
    
    if( $arg{is_first} ){
        
        $sql .= " limit 1 ";
    }else{
        
        $sql .= " limit $self->{limit} " if (defined $self->{limit});
        $sql .= " offset $self->{offset} " if (defined $self->{offset});
    }
    
    println_white( "_sql_compile= ", $sql );
    
    $sql;
}

=head2 select
    
    select('table.field1')
    
sub select {
    my $self = shift;
    
    push @{$self->{fields}}, @_;
    
    $self;
}
=cut

=head2 where
    
    where sentences
    
    where( id => 1 )
    where( id => [1,2,3] )
    where( 'name like ?', 'first%' )
    where( 'name like ? or title like ?', 'first%', 'second%' )
    
=cut
sub where {
    my $self = shift;
    #my %arg = @_;
    my $arg_cnt = scalar(@_);
    
    #my %fields = map {
    #    $_->{tablename} ne $self->{table_name} ? $_->{tablename}.'.'.$_->{name} : $_->{name} => $_
    #} @{$self->{fields}};
    
    #die dumper(\@_);
    
    if( $arg_cnt > 1 && ($arg_cnt % 2) == 0 && $_[0] !~ /\s/ ){
        
        println_yellow('where :1');
        
        while (my($name, $value) = splice(@_, 0, 2)) {
            if( ref $value eq 'ARRAY' ){
                
                my @v = map { $_ =~ s!'!&apos;!g; $_; } @$value;
                
                push @{$self->{where}}, "$name in ('".join("','", @v)."')";
            }else{
                push @{$self->{where}}, "$name = ?";
                push @{$self->{where_arg}}, $value;
            }
        }
        
    }elsif( $arg_cnt > 1 && $_[0] =~ /\s/ ){
        
        println_yellow('where :2');
        
        # where( 'name like ?', 'first%' )
        # where( 'name like ? or title like ?', 'first%', 'second%' )
        
        push @{$self->{where}}, shift;
        push @{$self->{where_arg}}, @_;
        
    }elsif( $arg_cnt == 1 && $_[0] =~ /\s/ ){
        
        println_yellow('where :3');
        
        # where( 'id = 99' )
        
        push @{$self->{where}}, $_[0];
    }
    
    
    
    $self;
}

sub limit {
    my $self = shift;
    
    $self->{limit} = $_[0];
    
    $self;
}

sub offset {
    my $self = shift;
    
    $self->{offset} = $_[0];
    
    $self;
}

sub gain {
    my $self = shift;
    
    push @{$self->{gain}}, @_;
    
    $self;
}

sub attach {
    my $self = shift;
    
    push @{$self->{attach}}, @_;
    
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
        
        $self->_fields_from_table( $table );
        
        push @{$self->{join}}, {
            prefix => join(' ', @table_expect),
            table  => $table,
            on     => $on_option ? $on_option : $self->_get_join_options( $table ),
        };
    } else {
        
        # join( 'users' )
        # join( 'users' => 'users.id = article.user_id' )
        
        $self->_fields_from_table( $table_expect[0] );
        
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

sub _reset {
    my $self = shift;
    
    $self->{where} = $self->{where_arg} = undef;
    $self->{join} = $self->{gain} = $self->{attach} = [];
    $self->{limit} = $self->{offset} = $self->{orderby} = undef;
}

sub list {
    my $self = shift;
    my %arg  = @_;
    
    #warn '$self->{fields} '.dumper($self->{fields});
    
    
    my @fields = map {
        $_->{tablename} ne $self->{table_name} ? $_->{tablename}.'.'.$_->{name} : $_->{name}
    } @{$self->{fields}};
    
    my %fields = map {
        $_->{tablename} ne $self->{table_name} ? $_->{tablename}.'.'.$_->{name} : $_->{name} => $_
    } @{$self->{fields}};
    
    # @fields has contain:
    # ["id", "user_id", "title", "body", "registered", "changed", "users.id", "users.login", "users.password", "users.name", "users.registered", "users.changed"]
    
    my $list2;
    
    
    my $list = $self->db->selectall_arrayref( $self->_sql_compile, undef, @{$self->{where_arg}} );
    for my $row ( @$list ) {
        my $row2 = {};
        for ( my $i=0; $i<scalar @fields; $i++ ) {
            
            my $obj = dclone $fields{$fields[$i]};
            $obj->{value} = $row->[$i];
            
            $row2->{$fields[$i]} = $obj;
        }
        push @$list2, $row2;
    }
    
    
    for my $ga ( @{$self->{gain}} ) {
        
        # check
        my $ga_assign = '';
        my $ga_field = '';
        for my $f (qw(belong_to has_many)){
            for my $el ( @{$self->{$f}} ) {
                my @t = split(/\./, $el->[1]);
                
                if( $ga eq $t[0] ){
                    
                    $ga_assign = "select * from $ga where $el->[1] = ? ";
                    $ga_field  = $el->[0];
                }
            }
        }
        
        # set for each row
        for my $row ( @$list2 ) {
            
            $row->{$ga.'_raw_'} = $self->db->selectall_arrayref( $ga_assign, {Slice=>{}}, $row->{$ga_field}->value );
        }
    }
    
    if ( $arg{-data} ) {
        for my $row ( @$list2 ) {
            for my $key ( keys %$row ) {
                
                $row->{$key} = $row->{$key}->value if ( $row->{$key} && $key !~ /_raw_$/ );
                
                if( $arg{-json} ){
                    $row->{$key} =~ s!'!&apos;!g;
                    $row->{$key} =~ s!"!&quot;!g;
                }
            }
            
            if( $arg{-json} ){
                $row = JSON::XS->new->utf8->encode($row);
            }
        }
        
        
    }
    
    if ( $arg{-flat} ) {
        
        my @list3;
        
        for my $row ( @$list2 ) {
            
            my $row2 = {};
            
            for my $key ( keys %$row ) {
                
                if ($key =~ /_raw_$/){
                    $row2->{$key} = $row->{$key};
                    next;
                }
                
                $row2->{$key}->{ref} = ref $row->{$key};
                
                for my $f (qw(default extra name name_full not_null primary_key type value)) {
                    
                    my $vv = $row->{$key}->{$f};
                    
                    if ( $arg{-json} ) {
                        $vv =~ s!"!&quot;!g;
                        $row2->{$key}->{$f} = $vv;
                    }else{
                        $row2->{$key}->{$f} = $vv;
                    }
                }
                
            }
            
            if ( $arg{-json} ) {
                
                $row2 = JSON::XS->new->utf8->encode($row2);
                $row2 =~ s!'!&apos;!g;
                
                push @list3, $row2;
            }else{
                push @list3, $row2;
            }
        }
        
        @$list2 = @list3;
    }
    
    
    $self->_reset;
    
    $list2;
}

sub first__ {
    my $self = shift;
    my %arg  = @_;
    
    my @fields = map {
        $_->{tablename} ne $self->{table_name} ? $_->{tablename}.'.'.$_->{name} : $_->{name}
    } @{$self->{fields}};
    
    my %fields = map {
        $_->{tablename} ne $self->{table_name} ? $_->{tablename}.'.'.$_->{name} : $_->{name} => $_
    } @{$self->{fields}};
    
    my $list2;
    
    my $list = $self->db->selectall_arrayref( $self->_sql_compile(is_first => 1), undef, @{$self->{where_arg}} );
    
    for my $row ( @$list ) {
        my $row2 = {};
        for ( my $i=0; $i<scalar @fields; $i++ ) {
            
            my $obj = dclone $fields{$fields[$i]};
            $obj->{value} = $row->[$i];
            
            $row2->{$fields[$i]} = $obj;
        }
        push @$list2, $row2;
    }
    
    for my $ga ( @{$self->{gain}} ) {
        
        # check
        my $ga_assign = '';
        my $ga_field = '';
        for my $f (qw(belong_to has_many)){
            for my $el ( @{$self->{$f}} ) {
                my @t = split(/\./, $el->[1]);
                
                #warn "1: ga ($ga) t[0] ($t[0])";
                if( $ga eq $t[0] ){
                    
                    #warn "2: ga ($ga) t[0] ($t[0])";
                    
                    $ga_assign = "select * from $ga where $el->[1] = ? ";
                    $ga_field  = $el->[0];
                    
                    #warn "3: ga_assign ($ga_assign)";
                    #warn "3: ga_field ($ga_field)";
                }
            }
        }
        
        # set for each row
        for my $row ( @$list2 ) {
            
            $row->{$ga.'_raw_'} = $self->db->selectall_arrayref( $ga_assign, {Slice=>{}}, $row->{$ga_field}->value );
        }
    }
    
    for my $at ( @{$self->{attach}} ) {
        
        # check
        my $at_assign = '';
        for my $f (qw(belong_to has_many)){
            for my $el ( @{$self->{$f}} ) {
                my @t = split(/\./, $el->[1]);
                
                #warn "1: at ($at) t[0] ($t[0])";
                if( $at eq $t[0] ){
                    
                    #warn "2: at ($at) t[0] ($t[0])";
                    
                    $at_assign = "select * from $at ";
                    
                    #warn "3: at_assign ($at_assign)";
                }
            }
        }
        
        # set for each row
        for my $row ( @$list2 ) {
            
            $row->{$at.'_raw_'} = $self->db->selectall_arrayref( $at_assign, {Slice=>{}} );
        }
    }
    
    if ( $arg{-flat} ) {
        
        my @list3;
        
        for my $row ( @$list2 ) {
            
            my $row2 = {};
            
            for my $key ( keys %$row ) {
                
                if ($key =~ /_raw_$/){
                    $row2->{$key} = $row->{$key};
                    next;
                }
                
                $row2->{$key}->{ref} = ref $row->{$key};
                
                for my $f (qw(default extra name name_full not_null primary_key type value)) {
                    
                    my $vv = $row->{$key}->{$f};
                    
                    if ( $arg{-json} ) {
                        $vv =~ s!"!&quot;!g;
                        $row2->{$key}->{$f} = $vv;
                    }else{
                        $row2->{$key}->{$f} = $vv;
                    }
                }
                
            }
            
            if ( $arg{-json} ) {
                
                $row2 = JSON::XS->new->utf8->encode($row2);
                $row2 =~ s!'!&apos;!g;
                
                push @list3, $row2;
            }else{
                push @list3, $row2;
            }
        }
        
        @$list2 = @list3;
    }
    
    
    
    $self->_reset;
    $list2->[0];
}

sub count {
    my $self = shift;
    
    my $data = $self->db->selectrow_hashref( $self->_sql_compile(is_count => 1), undef, @{$self->{where_arg}} );
    
    $self->_reset;
    
    $data->{cnt};
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
