
package Controller::Admin::Vm;

use utf8;
use WB::Util qw(:def);
use Controller::Helper;

required 'App::auth_required';
template_layout 'admin';


sub show{
    my($self, $r, $args) = @_;
    
    my $vm = $r->vboxmanage->info_vm(UUID => $args->{uuid});
    $r->response->set404 if ( !$vm );
    
    my $list_vms = $r->vboxmanage->list_vms;
    for my $a (@$list_vms){
        $a->{css_state} = '';
        
        if( $a->{UUID} eq $args->{uuid} ){
            $a->{css_state} .= ' active';
        }
        if( $a->{VMState} eq 'running' ){
            $a->{css_state} .= ' text-success';
        }
        
    }
    
    $r->response->template_args(
        list_vms => $list_vms,
        vm_dump => dumper($vm),
        vm => encode_json($vm),
        head_title => 'VM '.$vm->{name},
    );
}

sub new{
    my($self, $r, $args) = @_;
    
    $r->response->template_args(
        list_vms => $r->vboxmanage->list_vms,
        head_title => 'Create new VM',
    );
}


1;
