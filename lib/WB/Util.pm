
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
    qw(dumper required template_layout),
    qw(encode_json decode_json),
    qw(print_red print_yellow),
);

our %EXPORT_TAGS = (def => [qw(dumper required template_layout encode_json decode_json print_red print_yellow)]);

sub print_red {
    print color('bold red').join(' ', @_).color('reset');
}

sub print_yellow {
    print color('bold yellow').join(' ', @_).color('reset');
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

sub required{ }

sub template_layout{ }

1;
