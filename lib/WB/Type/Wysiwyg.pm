
package WB::Type::Wysiwyg;

use base WB::Type::Text;

sub value {
    my $self  = shift;
    my $value = shift;
    
    $self->{value} = $value if ( defined $value );
    
    '[['.$self->{value}.']]';
}

1;
