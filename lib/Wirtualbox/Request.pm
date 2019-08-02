
package Wirtualbox::Request;

use strict;
use warnings;

use Wirtualbox::Util qw(dumper url_unescape decode);



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

sub env{
    my $o = shift;
    $o->{env};
}

sub charset{
    my $o = shift;
    $o->{charset};
}

sub path_info{
    my $o = shift;
    $o->{env} && $o->{env}{PATH_INFO} ? $o->{env}{PATH_INFO} : undef;
}

sub _param_parse{
    my $o = shift;
    
    print "_param_parse\n";
    
    if( $o->{env} && $o->{env}{REQUEST_METHOD} && $o->{env}{REQUEST_METHOD} eq 'GET' && length $o->{env}{QUERY_STRING} ){
        my $param = $o->{param} = [];
        my $charset = $o->charset;
        
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
}

sub param{
    my $o = shift;
    my $name = shift;
    
    $o->_param_parse if !$o->{param};
    
    #print dumper($o->{param});
    
    my @values;
    my $param = $o->{param} || [];
    for (my $i = 0; $i < @$param; $i += 2) {
        push @values, $param->[$i + 1] if $param->[$i] eq $name;
    }
    
    wantarray ? @values : \@values;
}

1;
