
package Model::Article;

use base WB::ModelCore;

__PACKAGE__->config(
    table_name => 'articles',
    #opt1 => 'xxx',
);

__PACKAGE__->belong_to( user_id => 'users.id' );

__PACKAGE__->has_many( id => 'comments.article_id' );

1;
