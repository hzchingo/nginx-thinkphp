FROM nginx:stable-alpine

# overwrites nginx default 'default.conf'
COPY nginx.vh.thinkphp.conf  /etc/nginx/conf.d/default.conf
