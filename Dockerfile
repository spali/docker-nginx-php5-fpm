FROM ubuntu:14.04

#######################################################################################

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r nginx && useradd -r -g nginx nginx

# install basics
RUN \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install curl git software-properties-common

# install nginx
RUN \
	add-apt-repository -y ppa:nginx/stable && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y nginx php5-fpm

# edit php5-fpm configuration
RUN sed -e 's/^\(\(user\|group\)\s*=\s*\).*/\1nginx/' \
	-e 's/^\(listen\.\(owner\|group\)\s*=\s*\).*/\1nginx/' \
        -e '/catch_workers_output/s/^;//' \
        -i /etc/php5/fpm/pool.d/www.conf

# edit nginx configuration
RUN sed -e '/\s*#location\s*~\s*\\\.php\$/ s/\(\s*\)#\(.*\)/\1\2 include snippets\/fastcgi-php.conf; fastcgi_pass unix:\/var\/run\/php5-fpm.sock; }/' \
	-i /etc/nginx/sites-enabled/default
RUN sed -e 's/^\(\user\s*\)[^\s;]*\(.*\)/\1nginx\2/' \
	-e '1,/^\s*$/ s/^\s*$/daemon off;\n/' \
	-e '1,/^\s*$/ s/^\s*$/error_log \/dev\/stdout info;\n/' \
	-i /etc/nginx/nginx.conf


# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

COPY docker-entrypoint.sh /
COPY docker-command.sh /
RUN chmod +x /docker-entrypoint.sh /docker-command.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

# expose port
EXPOSE 80
EXPOSE 443

# Define working directory.
WORKDIR /etc/nginx

CMD ["/docker-command.sh"]
#######################################################################################
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
