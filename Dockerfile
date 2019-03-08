FROM nginx:stable-alpine

# overwrites nginx default 'default.conf'
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.vh.thinkphp.conf  /etc/nginx/conf.d/default.template
RUN envsubst \$PHP_FPM_HOST < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ['/entrypoint.sh']
CMD ["run"]
