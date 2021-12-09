FROM nginx:1.20-alpine


RUN apk add --no-cache --update certbot tzdata openssl

ADD conf/nginx.conf /etc/nginx/nginx.conf

ADD script/entrypoint.sh /entrypoint.sh
ADD script/le.sh /le.sh
ADD script/changefqdn.sh /changefqdn.sh

RUN rm /etc/nginx/conf.d/default.conf && \
    chmod +x /entrypoint.sh && \
    chmod +x /le.sh && \
    chmod +x /changefqdn.sh

CMD ["/entrypoint.sh"]
