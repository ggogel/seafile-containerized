FROM alpine:3.18.8 AS get

RUN apk add --no-cache wget

ENV SEAFILE_VERSION=11.0.9

RUN cd /tmp && \
    wget https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz?nocache=$(date +%s) -O seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    tar -zxvf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    rm -f seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

FROM ubuntu:jammy@sha256:340d9b015b194dc6e2a13938944e0d016e57b9679963fdeb9ce021daac430221 AS pip

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
python3=3.10.6-1~22.04 \
python3-pip=22.0.2+dfsg-1ubuntu0.4 \
libldap2-dev=2.5.18+dfsg-0ubuntu0.22.04.2 \
libsasl2-dev=2.1.27+dfsg2-3ubuntu1.2 \
&& rm -rf /var/lib/apt/lists/*

RUN pip3 install --target /pip-deps --timeout=3600 --no-cache-dir \
sqlalchemy==2.0.31 \
click==8.1.7 \
termcolor==2.4.0 \
colorlog==6.8.2 \
pymysql==1.1.1 \
jinja2==3.1.4 \
pycryptodome==3.20.0 \
lxml==5.2.2 \
python-ldap==3.4.4

RUN find /pip-deps -name "__pycache__" -type d -exec rm -r {} + && \
    rm -rf /pip-deps/pip /pip-deps/wheel /pip-deps/setuptools

FROM ubuntu:jammy@sha256:340d9b015b194dc6e2a13938944e0d016e57b9679963fdeb9ce021daac430221

ENV SEAFILE_VERSION=11.0.9

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
netcat-openbsd=1.218-4ubuntu1 \
socat=1.7.4.1-3ubuntu4 \
cron=3.0pl1-137ubuntu3 \
tzdata=2024a-0ubuntu0.22.04.1 \
psmisc=23.4-2build3 \
net-tools=1.60+git20181103.0eebece-1ubuntu5 \
libmariadb-dev=1:10.6.18-0ubuntu0.22.04.1 \
ldap-utils=2.5.18+dfsg-0ubuntu0.22.04.2 \
ca-certificates=20230311ubuntu0.22.04.1 \
python3=3.10.6-1~22.04 \
&& rm -rf /var/lib/apt/lists/*

COPY --from=pip /pip-deps /usr/local/lib/python3.10/dist-packages

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
ln -sf /opt/seafile/logs/common.log /opt/seafile/logs/notification-server.log &&\
ln -sf /opt/seafile/logs/common.log /opt/seafile/logs/seafile-monitor.log &&\
mkdir -p /etc/ldap/ && echo "TLS_REQCERT     allow" >> /etc/ldap/ldap.conf

EXPOSE 8001 8080 8082 8083

CMD ["/scripts/start.sh"]
