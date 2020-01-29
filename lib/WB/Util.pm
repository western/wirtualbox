
package WB::Util;

use strict;
use warnings;

use Carp qw(carp croak);
use Data::Dumper ();
use JSON::XS;
use Exporter 'import';
use Encode 'find_encoding';
use Term::ANSIColor;


# Encoding and pattern cache
my (%ENCODING, %PATTERN);

our @EXPORT_OK = (
    qw(decode encode),
    qw(url_escape url_unescape),
    qw(dumper current_sql_datetime required template_layout),
    qw(encode_json decode_json),
    qw(println_red println_yellow println_white),
);

our %EXPORT_TAGS = (
    def => [qw(
        dumper current_sql_datetime required template_layout
        encode_json decode_json
        println_red println_yellow println_white
    )]
);

sub println_red {
    print color('bold red').join(' ', @_).color('reset')."\n";
}

sub println_yellow {
    print color('bold yellow').join(' ', @_).color('reset')."\n";
}

sub println_white {
    print color('bold white').join(' ', @_).color('reset')."\n";
}

sub decode {
    my ($encoding, $bytes) = @_;
    return undef unless eval { $bytes = _encoding($encoding)->decode("$bytes", 1); 1 };
    return $bytes;
}

sub encode {
    _encoding($_[0])->encode("$_[1]", 0)
}

sub _encoding {
    $ENCODING{$_[0]} //= find_encoding($_[0]) // croak "Unknown encoding '$_[0]'";
}

sub url_escape {
    my ($str, $pattern) = @_;

    if ($pattern) {
        unless (exists $PATTERN{$pattern}) {
            (my $quoted = $pattern) =~ s!([/\$\[])!\\$1!g;
            $PATTERN{$pattern}
                = eval "sub { \$_[0] =~ s/([$quoted])/sprintf '%%%02X', ord \$1/ge }"
                or croak $@;
        }
        $PATTERN{$pattern}->($str);
    } else {
        $str =~ s/([^A-Za-z0-9\-._~])/sprintf '%%%02X', ord $1/ge
    }
    
    return $str;
}

sub url_unescape {
    my $str = shift;
    $str =~ s/%([0-9a-fA-F]{2})/chr hex $1/ge;
    return $str;
}

sub dumper{
    Data::Dumper->new([@_])->Indent(1)->Sortkeys(1)->Terse(1)->Useqq(1)->Dump;
}

sub current_sql_datetime{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    
    $mon ++;
    $year += 1900;
    
    $mon  = "0$mon"  if( length($mon)<2 );
    $mday = "0$mday" if( length($mday)<2 );
    $hour = "0$hour" if( length($hour)<2 );
    $min  = "0$min"  if( length($min)<2 );
    $sec  = "0$sec"  if( length($sec)<2 );
    
    "$year-$mon-$mday $hour:$min:$sec";
}

sub required{ }

sub template_layout{ }

1;
