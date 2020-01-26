
package Model::Comment;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'comments' );

__PACKAGE__->belong_to( user_id => 'users.id' );

__PACKAGE__->belong_to( article_id => 'articles.id' );

1;
