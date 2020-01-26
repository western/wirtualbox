
package WB::Type::Edit;

use base WB::Type::Varchar;

sub value {
    my $self  = shift;
    my $value = shift;
    
    $self->{value} = $value if ( defined $value );
    
    'edit:'.$self->{value};
}

1;
