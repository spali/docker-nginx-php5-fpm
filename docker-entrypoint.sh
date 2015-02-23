#!/bin/bash
set -e

if [ "$1" = '/docker-command.sh' ]; then
	chown -R nginx:nginx /var/lib/nginx
	chown -R nginx:nginx /var/www/html
fi      

exec $@

