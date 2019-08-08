
package VBoxManage;

use strict;
use warnings;
use WB::Util qw(:def);



sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $o = {
        util => 'VBoxManage',
        %arg,
    };
    
    bless $o, $class;
    
    $o->_fill_list if( !$o->{list_vms} );
    
    $o;
}

sub _fill_list{
    my $o = shift;
    
    #warn "->_fill_list";
    
    my $run = com($o->{util}, 'list', 'vms');
    
    for my $s (split(/\n/, `$run`)){
        my($name, $uuid) = split(/\s+/, $s);
        
        $run = com($o->{util}, 'showvminfo', $uuid, '--machinereadable', '--details');
        my @out = split(/\n/, `$run`);
        my %out = map { my($n,$v) = split(/=/, $_); unquoted($n) => unquoted($v) } @out;
        
        push @{$o->{list_vms}}, \%out;
    }
    
    #die dumper $o->{list_vms}->[0];
    
    @{$o->{list_vms}} = sort { $a->{name} cmp $b->{name} } @{$o->{list_vms}};
}

sub list_vms{
    my $o = shift;
    $o->{list_vms};
}

sub list_vms_names{
    my $o = shift;
    my @a = map { $_->{name} } @{$o->{list_vms}};
    return \@a;
}

sub info_vm{
    my $o = shift;
    my %arg = @_;
    
    for my $a ( @{$o->{list_vms}} ){
        my $is_exist = 1;
        for my $k ( keys %arg ){
            if( $a->{$k} ne $arg{$k} ){
                $is_exist = 0;
                last;
            }
        }
        
        return $a if( $is_exist );
    }
    
    undef;
}

# utils

sub unquoted{
    my $s = shift;
    $s =~ s!^"|"$!!g;
    $s;
}

sub com{
    join(' ', @_);
}

1;
