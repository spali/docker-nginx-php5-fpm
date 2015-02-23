#!/bin/bash
set -e

/usr/sbin/php5-fpm --nodaemonize &
/usr/sbin/nginx &
wait

