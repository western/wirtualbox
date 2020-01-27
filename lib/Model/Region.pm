
package Model::Region;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'regions' );

__PACKAGE__->config( define_type => {
});



__PACKAGE__->has_many( id => 'articles.region_id' );

1;
