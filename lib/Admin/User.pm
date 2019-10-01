
package Admin::User;

use utf8;
use WB::Util qw(:def);
use MIME::Base64;

required 'Application::auth_required';
template_layout 'admin2';

sub index {
    my($self, $r, $args) = @_;
    
#     $r->response->template_file(
#         'template_file', 'template_layout'
#     );
    
#     $r->response->template_file(
#         'template_file'
#     );
    
    
#     $r->response->json({
#         code => 'non_ok',
#         msg => 'hi',
#     });
}

sub create {
    my($self, $r, $args) = @_;
    
    #warn dumper($args->{title});
    #warn dumper($args->{file});
    my($title, $file) = $r->param('title', 'file');
    #warn dumper($r);
    #warn dumper($title);
    #warn dumper($file);
    
    #() = (  =~ m!data:application/zip;base64,! );
    my @data = split(/,/, $file);
    
    
    open my $fl, '>', '/tmp/file.txt' or die $!;
    binmode $fl;
    print $fl decode_base64($data[1]);
    close $fl;
    
    
    $r->response->mode('json');
    $r->response->body({
        code => 'ok',
        info => 'get info',
    });
}

1;
