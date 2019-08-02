
UWSGI=/usr/sbin/uwsgi --plugins http,psgi --http :8090 --http-modifier1 5 --enable-threads --processes=2 --master
CHKSTATIC=--check-static htdocs
STATICMAP=--static-map /js=htdocs/js --static-map /favicon.ico=htdocs/favicon.ico --static-map /robots.txt=htdocs/robots.txt
PIDFILE=--pidfile /tmp/wirtualbox.pid
DAEMONIZE=--daemonize /tmp/wirtualbox.log
NOLOG=--disable-logging


debug:
	$(UWSGI) $(PIDFILE) $(STATICMAP) --psgi app.pl
run:
	$(UWSGI) $(PIDFILE) $(STATICMAP) --psgi app.pl $(DAEMONIZE)
kill:
	kill -9 `cat /tmp/wirtualbox.pid` ; rm /tmp/wirtualbox.log
getbootstrap:
	rm htdocs/bootstrap-4.3.1-dist.zip ; \
	wget -O htdocs/bootstrap-4.3.1-dist.zip https://github.com/twbs/bootstrap/releases/download/v4.3.1/bootstrap-4.3.1-dist.zip && \
	cd htdocs && \
	unzip bootstrap-4.3.1-dist.zip
