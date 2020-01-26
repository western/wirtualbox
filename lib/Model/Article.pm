
package Model::Article;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'articles' );

__PACKAGE__->config( define_type => {
    'articles.body'  => 'Wysiwyg',
    'articles.title' => 'Edit',
});

__PACKAGE__->belong_to( user_id => 'users.id' );

__PACKAGE__->belong_to( region_id => 'regions.id' );

__PACKAGE__->has_many( id => 'comments.article_id' );

1;
