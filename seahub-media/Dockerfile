FROM alpine:3.18.6 AS get
ENV SEAFILE_VERSION=11.0.7

RUN apk add --no-cache wget

RUN cd /tmp && \
    wget https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz?nocache=$(date +%s) -O seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    tar -zxvf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    rm -f seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

FROM caddy:2.7.6-alpine

COPY --from=get /tmp/seafile-server*/seahub/media /usr/share/caddy/media