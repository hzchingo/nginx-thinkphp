FROM nginx:stable-alpine

COPY nginx.vh.thinkphp.conf  /etc/nginx/conf.d/thinkphp.conf
