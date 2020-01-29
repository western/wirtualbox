
package Model::Perm;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'perm' );

__PACKAGE__->has_many( id => 'user_perm.perm_id' );

1;
