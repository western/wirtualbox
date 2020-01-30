
package Controller::Admin::Test;

use utf8;
use WB::Util qw(:def);

=head1 Test controller
    
    All tests will run in work environment
    
=cut

template_layout 'none';


sub orm {
    my($self, $r, $args) = @_;
    
    
    
    
    #my $list = $r->model->Article->join('left user')->join('left region')->limit($list_limit)->offset($list_offset)->list( -flat=>1, -json=>1, -row_as_obj=>'row' );
    #my $list_count = $r->model->Article->join('left user')->count;
    
    $r->response->json(
        ddd  => 'ff',
        a    => 1,
        some => [99, 95, 3],
    );
    
    
    $r->response->json({
        ddd => 'ff'
    });
}


1;
