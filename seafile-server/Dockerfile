FROM ubuntu:jammy@sha256:340d9b015b194dc6e2a13938944e0d016e57b9679963fdeb9ce021daac430221 AS build

RUN apt-get update && \
    apt-get install -y software-properties-common wget && \
    add-apt-repository ppa:longsleep/golang-backports

ENV SEAFILE_VERSION=11.0.9

WORKDIR /tmp
RUN wget https://raw.githubusercontent.com/haiwen/seafile-docker/master/build/seafile-build.sh
RUN wget https://raw.githubusercontent.com/haiwen/seafile-docker/master/build/seafile-build.py
RUN chmod +x ./seafile-build.sh
RUN ./seafile-build.sh ${SEAFILE_VERSION}

FROM alpine:3.20.2 AS clean

ENV SEAFILE_VERSION=11.0.9

COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION} /tmp/seafile-server-${SEAFILE_VERSION}

RUN rm -rf /tmp/seafile-server-${SEAFILE_VERSION}/seahub

FROM ubuntu:jammy@sha256:340d9b015b194dc6e2a13938944e0d016e57b9679963fdeb9ce021daac430221 AS pip

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
python3 \
python3-pip \
libldap2-dev \
libsasl2-dev \
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
python-ldap==3.4.4 \
pytz==2024.1 \
django==4.2.14 \
requests==2.32.3

RUN find /pip-deps -name "__pycache__" -type d -exec rm -r {} + && \
    rm -rf /pip-deps/pip /pip-deps/wheel /pip-deps/setuptools

FROM ubuntu:jammy@sha256:340d9b015b194dc6e2a13938944e0d016e57b9679963fdeb9ce021daac430221

ENV SEAFILE_VERSION=11.0.9

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

COPY --from=clean /tmp/seafile-server-${SEAFILE_VERSION} /opt/seafile/seafile-server-${SEAFILE_VERSION}
COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart/seafobj /opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart/seafobj
COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION}/seahub/scripts /opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub/scripts
COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION}/seahub/tools /opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub/tools
COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION}/seahub/sql /opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub/sql
COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION}/seahub/media/avatars /opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub/media/avatars
COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION}/seahub/seahub/settings.py /opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub/seahub/settings.py

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