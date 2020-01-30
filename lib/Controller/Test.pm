
package Controller::Test;

use utf8;
use WB::Util qw(:def);

=head1 Test controller
    
    All tests will run in work environment
    
=cut

template_layout 'none';


sub orm {
    my($self, $r, $args) = @_;
    
    my $list_limit = 0;
    my $list_offset = 0;
    
    $r->response->json(
        code => 'ok',
        #article_list  => $r->model->Article->join('left user')->join('left region')->limit($list_limit)->offset($list_offset)->list( -flat=>1, -json=>0 ),
        #article_list2 => $r->model->Article->join('left user')->join('left region')->limit($list_limit)->offset($list_offset)->list( -flat=>1, -json=>1, -row_as_obj=>'row' ),
        #article_list_count => $r->model->Article->join('left user')->count,
        
        article_list3 => $r->model->Article->join('uploadfile as uplf')->limit(1)->list( -flat=>1 )->[0],
    );
    
    
    
    
}


1;
