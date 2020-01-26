
package Model::Region;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'regions' );

__PACKAGE__->config( define_type => {
});

#__PACKAGE__->belong_to( user_id => 'users.id' );

#__PACKAGE__->has_many( id => 'comments.article_id' );

1;
