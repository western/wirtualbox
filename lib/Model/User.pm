
package Model::User;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'user' );

__PACKAGE__->has_many( id => 'user_perm.user_id' );

#__PACKAGE__->through( 'user_perm' => 'perm' );

1;
