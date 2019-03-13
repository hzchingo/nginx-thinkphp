#!usr/bin/env sh

set -e
sh ./nginx-config.sh > /etc/nginx/conf.d/default.conf

if [ "$1" = 'run' ]; then
    exec $(which nginx) -g "daemon off;"
else
    exec "$@"
fi
