#!/bin/sh
set -eu

: "${PORT:=10000}"
export PORT

envsubst '${PORT}' \
    < /etc/nginx/templates/default.conf.template \
    > /etc/nginx/conf.d/default.conf

php-fpm -D
exec nginx -g 'daemon off;'
