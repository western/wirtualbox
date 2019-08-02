
package Wirtualbox::Request;

use strict;
use warnings;

use HTTP::Entity::Parser;

use Wirtualbox::Util qw(dumper url_unescape decode);
use Wirtualbox::File;


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $o = {
        env => {},
        charset => 'UTF-8',
        %arg,
    };
    
    bless $o, $class;
}

sub charset{
    my $o = shift;
    $o->{charset};
}

sub path_info{
    my $o = shift;
    $o->{env} && $o->{env}{PATH_INFO} ? $o->{env}{PATH_INFO} : undef;
}

sub http_referer{
    my $o = shift;
    $o->{env} && $o->{env}{HTTP_REFERER} ? $o->{env}{HTTP_REFERER} : undef;
}

sub request_method{
    my $o = shift;
    $o->{env} && $o->{env}{REQUEST_METHOD} ? $o->{env}{REQUEST_METHOD} : undef;
}

sub _param_parse{
    my $o = shift;
    
    #print "_param_parse\n";
    
    if( $o->{env} && $o->{env}{REQUEST_METHOD} eq 'GET' && length $o->{env}{QUERY_STRING} ){
        my $param = $o->{param} = [];
        my $charset = $o->charset;
        
        #print "_GET_parse\n";
        
        for my $pair (split '&', $o->{env}{QUERY_STRING}) {
            next unless $pair =~ /^([^=]+)(?:=(.*))?$/;
            my ($name, $value) = ($1, $2 // '');
            
            # Replace "+" with whitespace, unescape and decode
            s/\+/ /g for $name, $value;
            $name  = url_unescape $name;
            $name  = decode($charset, $name) // $name if $charset;
            $value = url_unescape $value;
            $value = decode($charset, $value) // $value if $charset;
            
            push @$param, $name, $value;
        }
    }
    
    if( $o->{env} && $o->{env}{REQUEST_METHOD} eq 'POST' ){
        
        #print "_POST_parse\n";
        
        my $length = 0;
        if ($o->{env}{'psgix.input.buffered'}) {
            $length = 1024 * 1024; # 1MB for buffered
        } else {
            $length = 1024 * 64; # 64K for unbuffered
        }
        
        my $parser = HTTP::Entity::Parser->new(buffer_length => $length);
        $parser->register('application/x-www-form-urlencoded', 'HTTP::Entity::Parser::UrlEncoded');
        $parser->register('multipart/form-data', 'HTTP::Entity::Parser::MultiPart');
        
        if( my(@args) = $parser->parse($o->{env}) ){
            
            #print 'parser_dumper='.dumper(\@args);
            
            my @b;
            for (my $i = 0; $i < @{$args[1]}; $i += 2) {
                
                my $ar = $args[1][$i+1];
                
                push @b, $args[1][$i];
                push @b, new Wirtualbox::File(
                    filename => $ar->{filename},
                    size => $ar->{size},
                    tempname => $ar->{tempname},
                );
            }
            
            $o->{param} = [@{$args[0]}, @b];
        }
        
    }
}

sub param{
    my $o = shift;
    my $name = shift;
    
    
    
    #print '1. pid='.$$.' path_info='.$o->path_info.' '.dumper($o->{param});
    
    $o->_param_parse if !$o->{param};
    
    #print '2. pid='.$$.' path_info='.$o->path_info.' '.dumper($o->{param});
    
    my @values;
    my $param = $o->{param} || [];
    for (my $i = 0; $i < @$param; $i += 2) {
        push @values, $param->[$i + 1] if $param->[$i] eq $name;
    }
    
    #print "$$ get param '$name'\n";
    #print '@values='.dumper(\@values);
    
    #wantarray ? @values : \@values;
    return $values[0] if( scalar @values == 1 );
    return @values;
}


1;
