FROM caddy:2.6.4-alpine

RUN apk add --no-cache \
bash \
bind-tools

COPY Caddyfile /etc/caddy/Caddyfile
COPY scripts /scripts
RUN chmod u+x /scripts/*

CMD ["/scripts/start.sh"]