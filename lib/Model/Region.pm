
package Model::Region;

use base WB::ModelCore;

__PACKAGE__->config( table_name => 'region' );

__PACKAGE__->has_many( id => 'article.region_id' );

1;
