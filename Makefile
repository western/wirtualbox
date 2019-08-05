
UWSGI=/usr/sbin/uwsgi --plugins http,psgi --http :8090 --http-modifier1 5 --enable-threads --processes=2 --master
CHKSTATIC=--check-static htdocs
STATICMAP=--static-map /js=htdocs/js --static-map /css=htdocs/css --static-map /favicon.ico=htdocs/favicon.ico --static-map /robots.txt=htdocs/robots.txt
PIDFILE=--pidfile /tmp/wb.pid
DAEMONIZE=--daemonize /tmp/wb.log
NOLOG=--disable-logging

debug:
	$(UWSGI) $(PIDFILE) $(CHKSTATIC) --psgi app.pl
run:
	$(UWSGI) $(PIDFILE) $(CHKSTATIC) --psgi app.pl $(DAEMONIZE)
kill:
	kill -9 `cat /tmp/wb.pid` ; rm /tmp/wb.log
getbootstrap:
	cd htdocs ; \
	rm bootstrap-4.3.1-dist.zip ; \
	wget -O bootstrap-4.3.1-dist.zip https://github.com/twbs/bootstrap/releases/download/v4.3.1/bootstrap-4.3.1-dist.zip && \
	unzip bootstrap-4.3.1-dist.zip && \
	rm bootstrap-4.3.1-dist.zip
getjquery:
	cd htdocs/js ; \
	rm jquery-3.4.1.min.js ; \
	wget -O jquery-3.4.1.min.js https://code.jquery.com/jquery-3.4.1.min.js
test:
	prove
