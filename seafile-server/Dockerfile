FROM alpine:3.18.6 AS get

RUN apk add --no-cache wget

ENV SEAFILE_VERSION=11.0.6

RUN cd /tmp && \
    wget https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz?nocache=$(date +%s) -O seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    tar -zxvf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    rm -f seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

FROM ubuntu:jammy@sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e AS pip

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
python3 \
python3-pip \
libldap2-dev \
libsasl2-dev \
&& rm -rf /var/lib/apt/lists/*

RUN pip3 install --target /pip-deps --timeout=3600 --no-cache-dir \
sqlalchemy==2.0.29 \
click==8.1.7 \
termcolor==2.4.0 \
colorlog==6.8.2 \
pymysql==1.1.0 \
jinja2==3.1.3 \
pycryptodome==3.20.0 \
lxml==5.2.1 \
python-ldap==3.4.4

RUN find /pip-deps -name "__pycache__" -type d -exec rm -r {} + && \
    rm -rf /pip-deps/pip /pip-deps/wheel /pip-deps/setuptools

FROM ubuntu:jammy@sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e

ENV SEAFILE_VERSION=11.0.6

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
netcat-openbsd \
socat \
cron \
tzdata \
psmisc \
net-tools \
libmariadb-dev \
ldap-utils \
ca-certificates \
python3 \
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
