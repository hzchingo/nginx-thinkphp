FROM nginx:stable-alpine

# overwrites nginx default 'default.conf'
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.vh.thinkphp.conf  /etc/nginx/conf.d/default.template

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#ENTRYPOINT ['/entrypoint.sh']
CMD ["/entrypoint.sh", "run"]
