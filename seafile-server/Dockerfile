FROM alpine:3.17.4 AS get

RUN apk add --no-cache wget

ENV SEAFILE_SERVER=seafile-server SEAFILE_VERSION=10.0.1

RUN cd /tmp && \
    wget https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    tar -zxvf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    rm -f seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

FROM ubuntu:jammy-20230308

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
socat \
cron \
tzdata \
psmisc \
net-tools \
libmariadb-dev \
ldap-utils \
ca-certificates \
python3 \
python3-click \
python3-termcolor \
python3-colorlog \
python3-pymysql \
python3-jinja2 \
python3-sqlalchemy \
python3-pycryptodome \
python3-lxml \
&& rm -rf /var/lib/apt/lists/*

RUN cp -r  /usr/lib/python3/dist-packages/Cryptodome /usr/lib/python3/dist-packages/Crypto

ENV SEAFILE_VERSION=10.0.1

COPY --from=get /tmp/seafile-server-${SEAFILE_VERSION} /opt/seafile/seafile-server-${SEAFILE_VERSION}
COPY scripts /scripts
RUN chmod u+x /scripts/*

RUN mkdir -p /opt/seafile/logs &&\
touch /opt/seafile/logs/common.log &&\
ln -sf /opt/seafile/logs/common.log /opt/seafile/logs/seafile.log &&\
ln -sf /opt/seafile/logs/common.log /opt/seafile/logs/controller.log &&\
ln -sf /opt/seafile/logs/common.log /opt/seafile/logs/ccnet.log &&\
ln -sf /opt/seafile/logs/common.log /opt/seafile/logs/gc.log &&\
ln -sf /opt/seafile/logs/common.log /opt/seafile/logs/seafdav.log &&\
echo "TLS_REQCERT     allow" >> /etc/ldap/ldap.conf

EXPOSE 8080 8082 8001

CMD ["/scripts/start.sh"]
