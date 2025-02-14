FROM ubuntu:jammy@sha256:0e5e4a57c2499249aafc3b40fcd541e9a456aab7296681a3994d631587203f97 AS build

RUN apt-get update && \
    apt-get install -y software-properties-common wget && \
    add-apt-repository ppa:longsleep/golang-backports

ENV SEAFILE_VERSION=11.0.13

WORKDIR /tmp
RUN wget https://raw.githubusercontent.com/haiwen/seafile-docker/master/build/seafile-build.sh
RUN wget https://raw.githubusercontent.com/haiwen/seafile-docker/master/build/seafile-build.py
RUN chmod +x ./seafile-build.sh
RUN ./seafile-build.sh ${SEAFILE_VERSION}

FROM alpine:3.21.3 AS clean

ENV SEAFILE_VERSION=11.0.13

COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION} /tmp/seafile-server-${SEAFILE_VERSION}

RUN rm -rf /tmp/seafile-server-${SEAFILE_VERSION}/seahub

FROM ubuntu:jammy@sha256:0e5e4a57c2499249aafc3b40fcd541e9a456aab7296681a3994d631587203f97 AS pip

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
python3 \
python3-pip \
libldap2-dev \
libsasl2-dev \
&& rm -rf /var/lib/apt/lists/*

RUN pip3 install --target /pip-deps --timeout=3600 --no-cache-dir \
sqlalchemy==2.0.36 \
click==8.1.8 \
termcolor==2.5.0 \
colorlog==6.9.0 \
pymysql==1.1.1 \
jinja2==3.1.5 \
pycryptodome==3.21.0 \
lxml==5.3.0 \
python-ldap==3.4.4 \
pytz==2024.2 \
django==4.2.17 \
requests==2.32.3 \
PyYAML==6.0.2 \
defusedxml==0.7.1 \
json5==0.9.28

RUN find /pip-deps -name "__pycache__" -type d -exec rm -r {} + && \
    rm -rf /pip-deps/pip /pip-deps/wheel /pip-deps/setuptools

FROM ubuntu:jammy@sha256:0e5e4a57c2499249aafc3b40fcd541e9a456aab7296681a3994d631587203f97

ENV SEAFILE_VERSION=11.0.13

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
COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart/wsgidav /opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart/wsgidav
COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart/gunicorn /opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart/gunicorn
COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart/pkg_resources /opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart/pkg_resources
COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart/setuptools /opt/seafile/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart/setuptools
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