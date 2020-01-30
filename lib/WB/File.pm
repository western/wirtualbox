
package WB::File;

use strict;
use warnings;
use WB::Util qw(:def);

use Image::ExifTool qw(:Public);
use Digest::MD5::File qw(file_md5_hex);


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        filename => '',
        ext      => '',
        size     => 0,
        width    => 0,
        height   => 0,
        tempname => '',
        md5      => '',
        
        %arg,
    };
    
    if( $self->{filename} && $self->{filename} =~ m!([^.]+)$!i ){
        $self->{ext} = $1;
        
        if( $self->{filename} =~ m!\.(tar\.gz)$!i ){
            $self->{ext} = $1;
        }
    }
    
    bless $self, $class;
    
    $self->tempname($self->{tempname});
    
    
    $self;
}

sub filename{
    my $self = shift;
    $self->{filename} = $_[0] if ($_[0]);
    $self->{filename};
}

sub ext{
    my $self = shift;
    $self->{ext} = $_[0] if ($_[0]);
    $self->{ext};
}

sub size{
    my $self = shift;
    $self->{size} = $_[0] if ($_[0]);
    $self->{size};
}

sub width{
    my $self = shift;
    $self->{width} = $_[0] if ($_[0]);
    $self->{width};
}

sub height{
    my $self = shift;
    $self->{height} = $_[0] if ($_[0]);
    $self->{height};
}

sub md5{
    my $self = shift;
    $self->{md5} = $_[0] if ($_[0]);
    $self->{md5};
}

sub tempname{
    my $self = shift;
    $self->{tempname} = $_[0] if ($_[0]);
    
    if( $self->{tempname} && -f $self->{tempname} ){
        
        my $info = ImageInfo($self->{tempname});
        
        $self->size( -s $self->{tempname} );
        $self->width( $info->{ImageWidth} );
        $self->height( $info->{ImageHeight} );
        $self->md5( file_md5_hex($self->{tempname}) );
    }
    
    $self->{tempname};
}

=head2 upload_to
    
    if( my $photo = $r->param('photo') ){
        
        $photo->upload_to(
            full_path => $r->{env}{root}.'/htdocs/img/'.$photo->filename,
            rewrite   => 0
        );
    }
    
=cut
sub upload_to{
    my $self = shift;
    my %arg = @_;
    
    my $save_full_name = '';
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
