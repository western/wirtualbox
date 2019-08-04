
package WB::File;

use strict;
use warnings;


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $o = {
        filename => '',
        ext => '',
        size => 0,
        tempname => '',
        %arg,
    };
    
    if( $o->{filename} && $o->{filename} =~ m!([^.]+)$!i ){
        $o->{ext} = $1;
        
        if( $o->{filename} =~ m!\.(tar\.gz)$!i ){
            $o->{ext} = $1;
        }
    }
    
    bless $o, $class;
}

sub filename{
    my $o = shift;
    $o->{filename};
}

sub ext{
    my $o = shift;
    $o->{ext};
}

sub size{
    my $o = shift;
    $o->{size};
}

sub tempname{
    my $o = shift;
    $o->{tempname};
}

sub upload_to{
    my $o = shift;
    my %arg = @_;
    
    my $save_full_name = '';
    if( $arg{path} ){
        $save_full_name = $arg{path}.'/'.$o->{filename};
    }
    if( $arg{full_path} ){
        $save_full_name = $arg{full_path};
    }
    
    if( $o->{filename} && $o->{size} && $o->{tempname} && -f $o->{tempname} && $save_full_name ){
        
        if( -f $save_full_name ){
            return 0 if !$arg{rewrite};
            unlink $save_full_name or warn "Could not unlink $save_full_name: $!";
        }
        
        open my $in, '<', $o->{tempname} or die $!;
        open my $out, '>', $save_full_name or die $!;
        
        binmode $in;
        binmode $out;
        
        print $out $_ while(<$in>);
        
        close $in;
        close $out;
        return 1;
    }
    
    return 0;
}

1;
