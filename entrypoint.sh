#!/bin/sh

set -e
envsubst \$PHP_FPM_HOST < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf

if [ "$1" = 'run' ]; then
    nginx -g "daemon off;"
fi
