FROM caddy:2.8.4-alpine

RUN apk add --no-cache \
    bash=5.2.26-r0 \
    bind-tools=9.18.27-r0

COPY Caddyfile /etc/caddy/Caddyfile
COPY scripts /scripts
RUN chmod u+x /scripts/*

ENV SEAFILE_SERVER_HOSTNAME=seafile-server
ENV SEAHUB_HOSTNAME=seahub
ENV SEAHUB_MEDIA_HOSTNAME=seahub-media

CMD ["/scripts/start.sh"]
