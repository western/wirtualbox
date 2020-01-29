
package WB::File;

use strict;
use warnings;
use WB::Util qw(:def);


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        filename => '',
        ext => '',
        size => 0,
        tempname => '',
        %arg,
    };
    
    if( $self->{filename} && $self->{filename} =~ m!([^.]+)$!i ){
        $self->{ext} = $1;
        
        if( $self->{filename} =~ m!\.(tar\.gz)$!i ){
            $self->{ext} = $1;
        }
    }
    
    bless $self, $class;
}

sub filename{
    my $self = shift;
    $self->{filename};
}

sub ext{
    my $self = shift;
    $self->{ext};
}

sub size{
    my $self = shift;
    $self->{size};
}

sub tempname{
    my $self = shift;
    $self->{tempname};
}

=head2 upload_to
    
    if( my $photo = $r->param('photo') ){
        
        $photo->upload_to(
            full_path => $r->{env}{root}.'/htdocs/img/'.$photo->filename,
        );
    }
    
    or
    
    if( my $photo = $r->param('photo') ){
        
        $photo->upload_to(
            path => $r->{env}{root}.'/htdocs/img/',
        );
    }
    
=cut
sub upload_to{
    my $self = shift;
    my %arg = @_;
    
    my $save_full_name = '';
    if( $arg{path} ){
        $save_full_name = $arg{path}.'/'.$self->{filename};
    }
    if( $arg{full_path} ){
        $save_full_name = $arg{full_path};
    }
    
    if( $self->{filename} && $self->{size} && $self->{tempname} && -f $self->{tempname} && $save_full_name ){
        
        if( -f $save_full_name ){
            return 0 if !$arg{rewrite};
            unlink $save_full_name or warn "Could not unlink $save_full_name: $!";
        }
        
        open my $in, '<', $self->{tempname} or die "$! ($self->{tempname})";
        open my $selfut, '>', $save_full_name or die "$! ($save_full_name)";
        
        binmode $in;
        binmode $selfut;
        
        print $selfut $_ while(<$in>);
        
        close $in;
        close $selfut;
        return 1;
    }
    
    return 0;
}

1;
