
UWSGI=/usr/sbin/uwsgi --plugins http,psgi --http :8090 --http-modifier1 5 --enable-threads --processes=5 --master
CHKSTATIC=--check-static htdocs
STATICMAP=--static-map /js=htdocs/js --static-map /favicon.ico=htdocs/favicon.ico
PIDFILE=--pidfile /tmp/wirtualbox.pid
DAEMONIZE=--daemonize /tmp/wirtualbox.log
NOLOG=--disable-logging



debug:
	$(UWSGI) $(PIDFILE) $(STATICMAP) --psgi app.pl
run:
	$(UWSGI) $(PIDFILE) $(STATICMAP) --psgi app.pl $(DAEMONIZE)
kill:
	kill -9 `cat /tmp/wirtualbox.pid` ; rm /tmp/wirtualbox.log
