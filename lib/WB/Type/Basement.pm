
package WB::Type::Basement;

use utf8;
use WB::Util qw(:def);

use DateTime;
use JSON::XS;


sub new {
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        name        => undef,
        type        => undef,
        not_null    => undef,
        primary_key => undef,
        default     => undef,
        extra       => undef,
        
        value       => undef,
        
        %arg
    };
    
    $self = bless $self, $class;
    
    #$self->_init();
    
    $self;
}

=head2 value
    
    getter and setter
    
=cut
sub value {
    my $self  = shift;
    my $value = shift;
    
    $self->{value} = $value if ( defined $value );
    
    $self->{value};
}

=head2 get_obj_datetime
    
    get DateTime object
    
=cut
sub get_obj_datetime {
    my $self = shift;
    
    if( $self->{value} && $self->{value} =~ m!(\d{4})-(\d{1,2})-(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})! ){
        
        my $dt = DateTime->new(
            year   => $1,
            month  => $2,
            day    => $3,
            
            hour   => $4,
            minute => $5,
            second => $6,
        );
        
        # $dt->add( hours => 3 );
        # $dt->subtract( hours => 3 );
        
        return $dt;
    }
}

=head2 decode_json
    
    decode string to hash
    
    with utf-8
    JSON::XS->new->utf8->decode
    
=cut
sub decode_json($) {
    my $self = shift;
    
    JSON::XS->new->utf8->decode( $self->{value} );
}

=head2 encode_json
    
    encode hash to string
    
=cut
sub encode_json($) {
    my $self = shift;
    
    JSON::XS->new->utf8->encode( $self->{value} );
}

1;
