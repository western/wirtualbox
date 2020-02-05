
package WB::ModelCore;

use strict;
use warnings;
use utf8;

use Encode qw(decode encode);
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

our $VERSION = '0.2';

our $storage = {};


sub new {
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        driver   => undef, # 'mysql', 'postgres', etc
        db       => undef, # DBI handler
        is_debug => 0,
        
        table_name   => undef,
        primary_name => undef, # primary key field name
        
        fields    => [], # array of WB::Type classes
        where     => [],
        where_arg => [],
        join      => [],
        
        limit   => undef,
        offset  => undef,
        orderby => [],
        
        %arg
    };
    
    $self = bless $self, $class;
    
    $self;
}

=head2 _set_db
    
    Set database driver name.
    Called it from Model constructor
    
=cut
sub _set_db {
    my $self = shift;
    $self->{driver} = $self->{db}->{Driver}{Name};
}

sub db {
    shift->{db};
}

=head2 _init
    
    - Set relations
    - Set table_name
    - Set fields
    
    Called it from Model constructor
    
=cut
sub _init {
    my $self = shift;
    my $pack = ref $self;
    
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
    
    
    
    
    my $sql = "from $self->{table_name} \n";
    for my $j ( @{$self->{join}} ) {
        
        # prefix contain: left, inner, outer
        $sql .= $j->{prefix}.' ' if ( $j->{prefix} );
        
        if( $j->{alias} ){
            
            for my $f ( @{$self->{fields}} ) {
                $f->{alias} = $j->{alias} if ( $f->{tablename} eq $j->{table} );
            }
            
            my $on = $j->{on};
            $on =~ s!$j->{table}!$j->{alias}!g;
            
            $sql .= 'join '.$j->{table}.' '.$j->{alias}."\n";
            $sql .= ' on '.$on."\n";
        }else{
            $sql .= 'join '.$j->{table}."\n";
            $sql .= ' on '.$j->{on}."\n";
        }
    }
    
    
    
    
    
    $sql .= "\n";
    
    
    if ( $self->{where} && scalar @{$self->{where}} ) {
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
    
    println_green( 'ModelCore::', '_sql_compile=', $sql ) if ($self->{is_debug});
    
    $sql;
}



=head2 where
    
    where sentences
    
    where( id => 1 )
    where( id => [1,2,3] )
    where( 'name like ?', 'first%' )
    where( 'name like ? or title like ?', 'first%', 'second%' )
    
=cut
sub where {
    my $self = shift;
    my $arg_cnt = scalar(@_);
    
    
    
    if( $arg_cnt > 1 && ($arg_cnt % 2) == 0 && $_[0] !~ /\s/ ){
        
        println_green('ModelCore::', 'where :1') if ($self->{is_debug});
        
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
        
        println_green('ModelCore::', 'where :2') if ($self->{is_debug});
        
        # where( 'name like ?', 'first%' )
        # where( 'name like ? or title like ?', 'first%', 'second%' )
        
        push @{$self->{where}}, shift;
        push @{$self->{where_arg}}, @_;
        
    }elsif( $arg_cnt == 1 && $_[0] =~ /\s/ ){
        
        println_green('ModelCore::', 'where :3') if ($self->{is_debug});
        
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




=head2 join
    
    join( 'users' )
    join( 'left users' )
    join( 'left outer users' )
    join( 'users' => 'users.id = article.user_id' )
    
=cut
sub join {
    my $self = shift;
    
    my $table_name = shift;
    
    
    
    my @table_expect = split(/\s+/, $table_name);
    my $on_option    = shift;
    
    # join( 'left users' )
    # join( 'left outer users' )
    # join( 'left users' => 'users.id = article.user_id' )
    if ( scalar @table_expect > 1 ) {
        
        my $table = pop @table_expect;
        
        $self->_fields_from_table( $table );
        my $get_join_options = $self->_get_join_options( $table );
        
        push @{$self->{join}}, {
            prefix => join(' ', @table_expect),
            table  => $table,
            on     => $on_option ? $on_option : $get_join_options->{on},
            alias  => $get_join_options->{alias},
        };
    } else {
        
        # join( 'users' )
        # join( 'users' => 'users.id = article.user_id' )
        
        $self->_fields_from_table( $table_expect[0] );
        my $get_join_options = $self->_get_join_options( $table_expect[0] );
        
        push @{$self->{join}}, {
            prefix => 'inner',
            table  => $table_expect[0],
            on     => $on_option ? $on_option : $get_join_options->{on},
            alias  => $get_join_options->{alias},
        };
    }
    
    #warn '$self->{join}= '.dumper($self->{join}) if ($self->{is_debug});
    
    
    $self;
}

sub _get_join_options {
    my $self  = shift;
    my $table = shift;
    
    
    for my $el ( @{$self->{belong_to}} ) {
        my @t = split(/\./, $el->[1]);
        if( $table eq $t[0] ){
            return {
                on    => $self->{table_name}.'.'.$el->[0].' = '.$el->[1],
                alias => $el->[2]->{alias},
            };
        }
    }
    
    for my $el ( @{$self->{has_many}} ) {
        my @t = split(/\./, $el->[1]);
        if( $table eq $t[0] ){
            return {
                on    => $self->{table_name}.'.'.$el->[0].' = '.$el->[1],
                alias => $el->[2]->{alias},
            };
        }
    }
}

sub _reset {
    my $self = shift;
    
    $self->{fields} = [];
    $self->_fields_from_table( $self->{table_name} );
    
    $self->{where} = $self->{where_arg} = undef;
    $self->{join}  = $self->{gain} = [];
    $self->{limit} = $self->{offset} = $self->{orderby} = undef;
}

sub list {
    my $self = shift;
    my %arg  = @_;
    
    
    
    
    
    
    
    
    
    my $sql = $self->_sql_compile;
    
    
    

    
    my @fields = map {
        ($_->{alias} || $_->{tablename}).'.'.$_->{name}
    } @{$self->{fields}};
    
    my %fields = map {
        ($_->{alias} || $_->{tablename}).'.'.$_->{name} => $_
    } @{$self->{fields}};
    
    
    
    
    $sql = 'select '.CORE::join(', ', @fields)."\n".$sql;
    warn '[['.$sql.']]' if ($self->{is_debug});
    
    
    
    
    @fields = map {
        $_->{tablename} eq $self->{table_name} ? $_->{name} : ($_->{alias} || $_->{tablename}).'.'.$_->{name}
    } @{$self->{fields}};
    
    %fields = map {
        $_->{tablename} eq $self->{table_name} ? $_->{name} : ($_->{alias} || $_->{tablename}).'.'.$_->{name} => $_
    } @{$self->{fields}};
    
    
    
    
    my $list2;
    
    my $list = $self->db->selectall_arrayref( $sql, undef, @{$self->{where_arg}} );
    for my $row ( @$list ) {
        my $row2 = {};
        for ( my $i=0; $i<scalar @fields; $i++ ) {
            
            my $obj = dclone $fields{$fields[$i]};
            $obj->{value} = decode('UTF-8', $row->[$i]);
            
            $row2->{$fields[$i]} = $obj;
        }
        push @$list2, $row2;
    }
    
    
    
    # list( -data=>1 )
    # list( -data=>1, -json=>1 )
    # list( -data=>1, -map=>sub{ [$_[0]->{id}, $_[0]->{title}] } )
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
                $row = JSON::XS->new->utf8(0)->encode($row);
            }
        }
        
        if ( my $m = $arg{-map} ) {
            
            my @list3;
            
            for my $row ( @$list2 ) {
                push @list3, $m->( $row );
            }
            
            @$list2 = @list3;
        }
    }
    
    # list( -flat=>1 )
    # list( -flat=>1, -json=>1, -row-as-obj=>'row' )
    # list( -flat=>1, -json=>1 )
    if ( $arg{-flat} ) {
        
        my @list3;
        
        for my $row ( @$list2 ) {
            
            my $row2 = {};
            
            for my $key ( keys %$row ) {
                
                if ($key =~ /_raw_$/){
                    $row2->{$key} = $row->{$key};
                    next;
                }
                
                $row2->{$key}->{class} = ref $row->{$key};
                
                for my $f (qw(default extra name name_full not_null primary_key type value)) {
                    
                    my $vv = $row->{$key}->{$f};
                    
                    if ( $arg{-json} ) {
                        $vv =~ s!"!&quot;!g if ($vv);
                        $row2->{$key}->{$f} = $vv;
                    }else{
                        $row2->{$key}->{$f} = $vv;
                    }
                }
                
            }
            
            if ( $arg{-json} ) {
                
                $row2 = JSON::XS->new->utf8(0)->encode($row2);
                $row2 =~ s!'!&apos;!g;
                
                if ( $arg{'-row_as_obj'} ) {
                    push @list3, { $arg{'-row_as_obj'} => $row2 };
                }else{
                    push @list3, $row2;
                }
            }else{
                
                push @list3, $row2;
            }
        }
        
        @$list2 = @list3;
    }
    
    
    
    $self->_reset;
    
    if ( $arg{-json_all} ) {
        return JSON::XS->new->utf8(0)->encode($list2);
    }else{
        return $list2;
    }
}

sub count {
    my $self = shift;
    
    my $data = $self->db->selectrow_hashref( 'select count(*) cnt '.$self->_sql_compile, undef, @{$self->{where_arg}} );
    
    $self->_reset;
    
    $data->{cnt};
}

=head2 insert
    
    my %r = map { $_ => $r->param($_) } @fields;
    $r{for_first_page} = $r->param('for_first_page') || 0;
    $r{region_id}      = $r->param('region_id') || 0;
    $r{user_id}        = 1;
    $r{registered}     = current_sql_datetime;
    $r{photo}          = $uploadfile->{id} if ($uploadfile);
    
    my $article = $r->model->Article->insert( %r );
    
    Return hash of inserted row.
    
=cut
sub insert {
    my $self = shift;
    my %arg  = @_;
    
    my @names = keys %arg;
    my $names = CORE::join(',', @names);
    my @values = map { '?' } @names;
    my $values = CORE::join(',', @values);
    
    @values = values %arg;
    
    $self->db->do("insert into $self->{table_name} ($names) values ($values) ", undef, @values) or die $self->db->errstr;
    
    if ( $self->{driver} eq 'mysql' ) {
        
        return $self->db->selectrow_hashref( "select * from $self->{table_name} where $self->{primary_name}=?", undef, $self->db->{mysql_insertid} );
    }
}

=head2 update
    
    my %r = map { $_ => $r->param($_) } @fields;
    $r{for_first_page} = $r->param('for_first_page') || 0;
    $r{region_id}      = $r->param('region_id') || 0;
    $r{changed}        = current_sql_datetime;
    $r{photo}          = $uploadfile->{id} if ($uploadfile);
    
    $r->model->Article->where( id => $id )->update( %r );
    
    Returns the number of rows affected or undef on error.
    A return value of -1 means the number of rows is not known, not applicable, or not available.
    
=cut
sub update {
    my $self = shift;
    my %arg  = @_;
    
    my @names = keys %arg;
    my $names = CORE::join('=?,', @names); $names .= '=?';
    
    my @values = values %arg;
    push @values, @{$self->{where_arg}};
    
    my $sql = '';
    if ( $self->{where} ) {
        $sql .= 'where '.CORE::join(' and ', @{$self->{where}});
    }
    
    $self->db->do("update $self->{table_name} set $names $sql ", undef, @values) or die $self->db->errstr;
}

sub delete {
    my $self = shift;
    
    my $sql = '';
    if ( $self->{where} ) {
        $sql .= 'where '.CORE::join(' and ', @{$self->{where}});
    }
    
    $self->db->do("delete from $self->{table_name} $sql ", undef, @{$self->{where_arg}}) or die $self->db->errstr;
}



# ------------------------------------------------------------------------------

sub config {
    my $package = shift;
    
    while (my($name, $value) = splice(@_, 0, 2)) {
        $WB::ModelCore::storage->{$package}->{config}->{$name} = $value;
    }
}

=head2 has_many
    
    Special sub for model relation init
    
    __PACKAGE__->has_many( id => 'comment.article_id' );
    
=cut
sub has_many {
    my $package = shift;
    
    my $field       = shift; # id
    my $table_field = shift; # comment.article_id
    my $opt         = shift; # { alias => 'ph' }
    
    push @{$WB::ModelCore::storage->{$package}->{has_many}}, [$field, $table_field, $opt];
}

=head2 belong_to
    
    Special sub for model relation init
    
    __PACKAGE__->belong_to( photo => 'uploadfile.id', { alias => 'ph' } );
    
=cut
sub belong_to {
    my $package = shift;
    
    my $field       = shift; # photo
    my $table_field = shift; # uploadfile.id
    my $opt         = shift; # { alias => 'ph' }
    
    push @{$WB::ModelCore::storage->{$package}->{belong_to}}, [$field, $table_field, $opt];
}

1;
