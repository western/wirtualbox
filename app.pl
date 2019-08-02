
use strict;
use warnings;

use utf8;

use lib 'lib';
use Wirtualbox::Request;
use Wirtualbox::Util qw(dumper);


# PSGI — интерфейс между web-серверами и web-приложениями на perl
# https://habr.com/ru/post/78377/

# Введение в разработку web-приложений на PSGI/Plack
# https://habr.com/ru/post/247545/

# CPAN PSGI reference
# https://metacpan.org/pod/PSGI

# Param parser
# https://metacpan.org/source/Mojo::Parameters
# https://metacpan.org/release/Plack/source/lib/Plack/Request.pm

# /usr/sbin/uwsgi --plugins http,psgi --http :8090 --http-modifier1 5 --psgi app.pl
# /usr/sbin/uwsgi --plugins http,psgi --http :8090 --http-modifier1 5 --enable-threads --processes=10 --master --static-map /js=htdocs/js --psgi app.pl
# --static-map /js=htdocs/js

#DAEMON_OPTS="--psgi $SERVICE_SCRIPT --enable-threads --processes=10 --master  --daemonize=$LOG --pidfile=$PID_FILE --uwsgi-socket=$SOCK.$NUM_SOCK"
#--declare-option '$@' --uid=$OWNER --gid=$GROUP --uwsgi-socket=$SOCK.{1..$NUM_SOCK}
#echo "CHECK COMMAND: " $DAEMON $DAEMON_OPTS

my $app = sub {
    my $env = shift;
    
    
    my $r = new Wirtualbox::Request(env => $env);
    
    
    
    if( $r->path_info =~ m!^/js! ){
        
        return [
            '404',
            [ 'Content-Type' => 'text/html' ],
            [
                '--404--<br>',
                '[', $r->path_info, ']',
            ],
        ];
    }
    
    if( my $file = $r->param('file2') ){
        
        print 'file2='.dumper($file);
        
        $file->upload_to(
            full_path => '/tmp/filename.'.$file->ext,
            rewrite => 1,
        );
    }
    
    return [
        '200',
        [ 'Content-Type' => 'text/html' ],
        [ 
            q~
                <form method=post >
                    <input type="hidden" name="hid1" value="val1">
                    <input type="hidden" name="hid2" value="val2">
                    <input type="hidden" name="hid2" value="val3">
                    <input type="submit" value="!Clickme">
                </form>
                
                <hr>
                
                <form method=post enctype="multipart/form-data">
                    <input type="hidden" name="hid1" value="val1">
                    <input type="hidden" name="hid2" value="val2">
                    <input type="hidden" name="hid2" value="val3">
                    <input type="file" name="file1" >
                    <input type="file" name="file2" >
                    <input type="submit" value="!Clickme 2">
                </form>
                
                <br><a href="?n1=value1&n1=value11&n2=value2">!Clickme</a><br>
            ~,
            #'n1='.dumper($r->param('n1')).'<br>',
            #'n2='.dumper($r->param('n2')).'<br>',
            "<h1>app.pl $$</h1>",
            "<pre>",
            dumper($env),
            "</pre>"
        ],
    ];
};

my $xheader = sub {
    my $env = shift;
    my $res = $app->($env);
    push @{$res->[1]}, 'X-PSGI-Used' => 1;
    return $res;
};
