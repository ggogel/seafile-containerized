FROM alpine:3.16.3 AS get
ENV SEAFILE_SERVER=seafile-server SEAFILE_VERSION=9.0.10

RUN apk add --no-cache wget

RUN cd /tmp && \
    wget https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    tar -zxvf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    rm -f seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

FROM caddy:2.6.3-alpine

COPY --from=get /tmp/seafile-server*/seahub/media /usr/share/caddy/media