
package WB::Template;

use strict;
use warnings;

use WB::Util qw(:def);

use Cwd;



sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        template_engine => 'Template', # 'Template', 'HTML::Template', 'Text::Xslate'
        template_object => undef,
        template_layout => '',
        template_file   => '',
        %arg,
    };
    
    bless $self, $class;
}

sub init{
    my $self = shift;
    
    if( $self->{template_engine} eq 'Template' ){
        
        require Template;
        
        $self->{template_object} = Template->new({
            INCLUDE_PATH => '/tmp',
            INTERPOLATE  => 0,
            ABSOLUTE     => 1,
        }) or die $Template::ERROR;
    }
    
    if( $self->{template_engine} eq 'HTML::Template' ){
        
        require HTML::Template;
        
        #$self->{template_object} = HTML::Template->new(filename  => 'template.tmpl');
    }
    
    if( $self->{template_engine} eq 'Text::Xslate' ){
        
        require Text::Xslate;
        
        $self->{template_object} = Text::Xslate->new();
    }
}

sub template_file{
    my $self = shift;
    my $cwd  = getcwd();
    $cwd .= '/template';
    
    $self->{template_file}   = $_[0] if ($_[0]);
    $self->{template_layout} = $_[1] if ($_[1]);
    
    if( $self->{template_layout} && $self->{template_layout} =~ m!none\.html$! ){
        $self->{template_layout} = 'none';
    }
    
    
    for my $n (qw(template_file template_layout)) {
        
        if( $self->{$n} && !-e $self->{$n} ){
            
            my $result_path;
            
            # if layout
            if ( !$result_path && -e $cwd.'/'.$self->{$n}.'.html' ) {
                $result_path = $cwd.'/'.$self->{$n}.'.html';
                println_cyan('Template::', "$n try sample1 $result_path");
            }
            
            #if ( !$result_path && -e $cwd.'/Controller/'.$self->{$n}.'.html' ) {
            #    $result_path = $cwd.'/'.$self->{$n}.'.html';
            #    println_cyan('Template::', "$n try sample2 $result_path");
            #}
            
            # if set simple name "template_file"
            my $route = $self->{route};
            if ( !$result_path && $route && $route->{action} ) {
                
                my @t = split(/::/, $route->{action});
                pop @t;
                
                $result_path = $cwd.'/Controller/'.join('/', @t).'/'.$self->{$n}.'.html';
                println_cyan('Template::', "$n try sample3 $result_path");
            }
            
            if ( $result_path && -e $result_path ) {
                $self->{$n} = $result_path;
                println_cyan('Template::', "$n is $result_path");
            }
        }
    }
    
    wantarray ? ($self->{template_file}, $self->{template_layout}) : $self->{template_file};
}

sub process{
    my $self = shift;
    my %arg = @_;
    my $to = $self->{template_object};
    my $selfut;
    my $cwd  = getcwd();
    $cwd .= '/template';
    
    if( $to && $self->{template_engine} eq 'Template' ){
        
        my $main = '';
        $to->process($self->{template_file}, \%arg, \$main) or die $to->error();
        
        if( $self->{template_layout} && $self->{template_layout} ne 'none' ){
            $arg{main} = $main;
            $to->process($self->{template_layout}, \%arg, \$selfut) or die $to->error();
        }else{
            $selfut = $main;
        }
    }
    
    if( $self->{template_engine} eq 'HTML::Template' ){
        
        $to = HTML::Template->new(
            filename          => $self->{template_file},
            path              => [$cwd],
            die_on_bad_params => 0,
            utf8              => 1
        );
        $to->param(%arg);
        my $main = $to->output;
        
        if( $self->{template_layout} && $self->{template_layout} ne 'none' ){
            $to = HTML::Template->new(
                filename          => $self->{template_layout},
                path              => [$cwd],
                die_on_bad_params => 0,
                utf8              => 1
            );
            $to->param(%arg);
            $to->param(main => $main);
            $selfut = $to->output;
        }else{
            $selfut = $main;
        }
    }
    
    if( $to && $self->{template_engine} eq 'Text::Xslate' ){
        
        my $main = $to->render($self->{template_file}, \%arg);
        
        if( $self->{template_layout} && $self->{template_layout} ne 'none' ){
            $arg{main} = $main;
            $selfut = $to->render($self->{template_layout}, \%arg);
        }else{
            $selfut = $main;
        }
    }
    
    $selfut;
}

1;
