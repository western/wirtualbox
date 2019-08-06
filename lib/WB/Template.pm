
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
        template_layout => '',
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
    $o->{template_layout} = $_[1] if ($_[1]);
    
    if( $o->{template_layout} && $o->{template_layout} =~ m!none\.html$! ){
        $o->{template_layout} = 'none';
    }
    
    wantarray ? ($o->{template_file}, $o->{template_layout}) : $o->{template_file};
}

sub process{
    my $o = shift;
    my %arg = @_;
    my $to = $o->{template_object};
    my $out;
    
    if( $to && $o->{template_engine} eq 'Template' ){
        
        my $main = '';
        $to->process($o->{template_file}, \%arg, \$main) or die $to->error();
        
        if( $o->{template_layout} && $o->{template_layout} ne 'none' ){
            $to->process($o->{template_layout}, {main => $main}, \$out) or die $to->error();
        }else{
            $out = $main;
        }
    }
    
    if( $o->{template_engine} eq 'HTML::Template' ){
        
        
        $to = HTML::Template->new(filename => $o->{template_file});
        $to->param(%arg);
        my $main = $to->output;
        
        if( $o->{template_layout} && $o->{template_layout} ne 'none' ){
            $to = HTML::Template->new(filename => $o->{template_layout});
            $to->param(main => $main);
            $out = $to->output;
        }else{
            $out = $main;
        }
    }
    
    $out;
}

1;
