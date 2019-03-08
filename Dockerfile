FROM nginx:stable-alpine

# overwrites nginx default 'default.conf'
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.vh.thinkphp.conf  /etc/nginx/conf.d/default.template
CMD ["envsubst < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf"
CMD ["nginx", "-g", "daemon off;"]
