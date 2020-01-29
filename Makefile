
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
	rm jquery-3.4.1.js ; \
	wget -O jquery-3.4.1.js https://code.jquery.com/jquery-3.4.1.js ; \
	rm jquery-3.4.1.min.js ; \
	wget -O jquery-3.4.1.min.js https://code.jquery.com/jquery-3.4.1.min.js
getvuejs:
	cd htdocs/js ; \
	rm vue.js ; \
	wget -O vue.js https://vuejs.org/js/vue.js ; \
	rm vue.min.js ; \
	wget -O vue.min.js https://vuejs.org/js/vue.min.js
getcapicon:
	cd htdocs ; \
	rm -rf capicon ; \
	wget -O capicon.zip https://mariodelvalle.github.io/CaptainIcon/capicon.zip && unzip capicon.zip && rm capicon.zip && rm -rf __MACOSX
getfontawesome:
	cd htdocs ; \
	rm -rf fontawesome-free-5.12.0-web ; \
	wget https://use.fontawesome.com/releases/v5.12.0/fontawesome-free-5.12.0-web.zip && unzip fontawesome-free-5.12.0-web.zip && rm fontawesome-free-5.12.0-web.zip
test:
	prove
