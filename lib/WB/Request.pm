
package WB::Request;

use strict;
use warnings;

use HTTP::Entity::Parser;
use Cookie::Baker ();
use JSON::XS;
use Crypt::CBC;

use WB::Util qw(dumper url_unescape decode);
use WB::File;


sub new{
    my $c = shift;
    my $class = ref $c || $c;
    my %arg = @_;
    
    my $self = {
        env => {},
        charset => 'UTF-8',
        %arg,
    };
    
    bless $self, $class;
}

# virtual methods

# sub vboxmanage{
#     my $self = shift;
#     $self->{vboxmanage};
# }

sub model{
    my $self = shift;
    $self->{model};
}

sub db{
    my $self = shift;
    $self->{db};
}

sub response{
    my $self = shift;
    $self->{response};
}

# origin methods

sub charset{
    my $self = shift;
    $self->{charset};
}

sub path_info{
    my $self = shift;
    $self->{env} && $self->{env}{PATH_INFO} ? $self->{env}{PATH_INFO} : undef;
}

sub http_referer{
    my $self = shift;
    $self->{env} && $self->{env}{HTTP_REFERER} ? $self->{env}{HTTP_REFERER} : undef;
}

sub request_method{
    my $self = shift;
    $self->{env} && $self->{env}{REQUEST_METHOD} ? $self->{env}{REQUEST_METHOD} : undef;
}

sub remote_addr{
    my $self = shift;
    $self->{env} && $self->{env}{REMOTE_ADDR} ? $self->{env}{REMOTE_ADDR} : undef;
}

sub _param_parse{
    my $self = shift;
    
    #print "_param_parse\n";
    
    if( $self->{env} && $self->{env}{REQUEST_METHOD} eq 'GET' && length $self->{env}{QUERY_STRING} ){
        my $param = $self->{param} = [];
        my $charset = $self->charset;
        
        #print "_GET_parse\n";
        
        for my $pair (split '&', $self->{env}{QUERY_STRING}) {
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
    
    if( $self->{env} && $self->{env}{REQUEST_METHOD} eq 'POST' ){
        
        #print "_POST_parse\n";
        
        my $length = 0;
        if ($self->{env}{'psgix.input.buffered'}) {
            $length = 1024 * 1024; # 1MB for buffered
        } else {
            $length = 1024 * 64; # 64K for unbuffered
        }
        
        my $parser = HTTP::Entity::Parser->new(buffer_length => $length);
        $parser->register('application/x-www-form-urlencoded', 'HTTP::Entity::Parser::UrlEncoded');
        $parser->register('multipart/form-data', 'HTTP::Entity::Parser::MultiPart');
        
        if( my(@args) = $parser->parse($self->{env}) ){
            
            #print 'parser_dumper='.dumper(\@args);
            
            my @b;
            for (my $i = 0; $i < @{$args[1]}; $i += 2) {
                
                my $ar = $args[1][$i+1];
                
                push @b, $args[1][$i];
                push @b, new WB::File(
                    filename => $ar->{filename},
                    size => $ar->{size},
                    tempname => $ar->{tempname},
                );
            }
            
            $self->{param} = [@{$args[0]}, @b];
        }
        
    }
}

sub param{
    my $self = shift;
    my @names = @_;
    
    
    
    #print '1. pid='.$$.' path_info='.$self->path_info.' '.dumper($self->{param});
    
    $self->_param_parse if !$self->{param};
    
    #print '2. pid='.$$.' path_info='.$self->path_info.' '.dumper($self->{param});
    
    my @values;
    my $param = $self->{param} || [];
    for (my $i = 0; $i < @$param; $i += 2) {
        #push @values, $param->[$i + 1] if $param->[$i] eq $name;
        push @values, $param->[$i + 1] if grep(/^$param->[$i]$/, @names);
    }
    
    #print "$$ get param '$name'\n";
    #print '@values='.dumper(\@values);
    
    #wantarray ? @values : \@values;
    return $values[0] if( scalar @values == 1 );
    return @values;
}

sub cookie{
    my $self = shift;
    my $name = shift;
    my %arg = @_;
    
    return undef unless($self->{env}{HTTP_COOKIE});
    
    $self->{cookie} = Cookie::Baker::crush_cookie($self->{env}{HTTP_COOKIE}) unless($self->{cookie});
    
    my $ret = $self->{cookie}{$name};
    
    if( $arg{decrypt} && $ret ){
        my $cipher = Crypt::CBC->new(
            -key => $self->{secret},
            -cipher => 'Blowfish',
        );
        $ret = $cipher->decrypt_hex($ret);
    }
    
    if( $arg{json} && $ret ){
        $ret = JSON::XS->new->utf8->decode($ret);
    }
    
    $ret;
}

1;
