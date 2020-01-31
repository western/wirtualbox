
package Model::Article;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'article' );

__PACKAGE__->config( define_type => {
    'article.body'  => 'Wysiwyg',
    'article.title' => 'Edit',
    'article.photo' => 'Uploadfile',
});

__PACKAGE__->belong_to( user_id => 'user.id' );

__PACKAGE__->belong_to( region_id => 'region.id' );

__PACKAGE__->belong_to( photo => 'uploadfile.id' );

__PACKAGE__->has_many( id => 'comment.article_id' );

1;
