FROM caddy:2.7.5-alpine

RUN apk add --no-cache \
bash \
bind-tools

COPY Caddyfile /etc/caddy/Caddyfile
COPY scripts /scripts
RUN chmod u+x /scripts/*

ENV SEAFILE_SERVER_HOST=seafile-server
ENV SEAHUB_SERVER_HOST=seahub
ENV SEAHUB_MEDIA_SERVER_HOST=seahub-media

CMD ["/scripts/start.sh"]
