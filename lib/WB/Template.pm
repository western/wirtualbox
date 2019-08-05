
package WB::Template;

use strict;
use warnings;

use WB::Util qw(dumper);


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $o = {
        template_engine => 'Template',
        template_object => undef,
        template_main => '',
        template_file => '',
        %arg,
    };
    
    bless $o, $class;
}

sub init{
    my $o = shift;
    
    if( $o->{template_engine} eq 'Template' ){
        
        require Template;
        
        $o->{template_object} = Template->new({
            INCLUDE_PATH => '/tmp',
            INTERPOLATE  => 0,
            ABSOLUTE     => 1,
        }) or die $Template::ERROR;
    }
    
    if( $o->{template_engine} eq 'HTML::Template' ){
        
        require HTML::Template;
        
        #$o->{template_object} = HTML::Template->new(filename  => 'template.tmpl');
    }
}

sub template_file{
    my $o = shift;
    
    $o->{template_file} = $_[0] if ($_[0]);
    $o->{template_file};
}

sub process{
    my $o = shift;
    my %arg = @_;
    my $to = $o->{template_object};
    my $out;
    
    if( $to && $o->{template_engine} eq 'Template' ){
        
        $to->process($o->{template_file}, \%arg, \$out) or die $to->error();
    }
    
    if( $o->{template_engine} eq 'HTML::Template' ){
        
        $to = HTML::Template->new(filename => $o->{template_file});
        $to->param(%arg);
        $out = $to->output;
    }
    
    $out;
}

1;
