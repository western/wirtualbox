
package Model::Comment;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'comment' );

__PACKAGE__->belong_to( user_id => 'user.id' );

__PACKAGE__->belong_to( article_id => 'article.id' );

1;
