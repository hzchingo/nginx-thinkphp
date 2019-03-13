FROM nginx:stable-alpine

# overwrites nginx default 'default.conf'
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx-config.sh  /nginx-config.sh

COPY entrypoint.sh /entrypoint.sh
RUN ["chmod", "755", "/entrypoint.sh"]

#ENTRYPOINT ['/entrypoint.sh']
CMD ["/entrypoint.sh", "run"]
