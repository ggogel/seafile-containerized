FROM alpine:3.13 AS get

RUN apk add --no-cache wget

ENV SEAFILE_SERVER=seafile-server SEAFILE_VERSION=8.0.3

RUN cd /tmp && \
    wget https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    tar -zxvf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    rm -f seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

FROM ubuntu:bionic

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
socat \
tzdata \
psmisc \
net-tools \
libmariadb-dev \
python3 \
python3-click \
python3-termcolor \
python3-colorlog \
python3-pymysql \
python3-jinja2 \
python3-sqlalchemy \
&& rm -rf /var/lib/apt/lists/*

ENV SEAFILE_VERSION=8.0.3

COPY --from=get /tmp/seafile-server-${SEAFILE_VERSION} /opt/seafile/seafile-server-${SEAFILE_VERSION}
COPY scripts /scripts
RUN chmod u+x /scripts/*

RUN mkdir -p /opt/seafile/logs &&\
ln -sf /dev/stdout /opt/seafile/logs/seafile.log &&\
ln -sf /dev/stdout /opt/seafile/logs/controller.log &&\
ln -sf /dev/stdout /opt/seafile/logs/ccnet.log

EXPOSE 8080 8082 8001

CMD ["/scripts/start.sh"]
