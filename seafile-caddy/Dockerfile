FROM caddy:2.8.4-alpine

RUN apk add --no-cache \
bash \
bind-tools

COPY Caddyfile /etc/caddy/Caddyfile
COPY scripts /scripts
RUN chmod u+x /scripts/*

ENV SEAFILE_SERVER_HOSTNAME=seafile-server
ENV SEAHUB_HOSTNAME=seahub
ENV SEAHUB_MEDIA_HOSTNAME=seahub-media

CMD ["/scripts/start.sh"]
