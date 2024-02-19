FROM alpine:3.18.5 AS get
ENV SEAFILE_VERSION=11.0.5

RUN apk add --no-cache wget

RUN cd /tmp && \
    wget https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz?nocache=$(date +%s) -O seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    tar -zxvf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    rm -f seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

RUN sed -i "s@.*INNER_FILE_SERVER_ROOT.*@INNER_FILE_SERVER_ROOT = os.environ.get('INNER_FILE_SERVER_ROOT')@" /tmp/seafile-server-${SEAFILE_VERSION}/seahub/seahub/settings.py

RUN sed -i '/warning_if_seafile_not_running;/d' /tmp/seafile-server-${SEAFILE_VERSION}/seahub.sh

FROM python:3.10.13-alpine3.18 AS pip

RUN apk add --no-cache \
mariadb-dev \
build-base \
jpeg-dev \
zlib-dev \
freetype-dev \
lcms2-dev \
openjpeg-dev \
tiff-dev \
tk-dev \
tcl-dev \
libmemcached-dev \
openldap-dev \
python3-dev

RUN python3 -m pip install --upgrade pip &&\
pip3 install --target /pip-deps --timeout=3600 --no-cache-dir  \
future==0.18.3 \
pillow==10.2.0 \
captcha==0.4 \
pyjwt==2.6.0 \
mysqlclient==2.1.1 \
django==3.2.24 \
django-pylibmc==0.6.1 \
django-simple-captcha==0.5.20 \
pycryptodome==3.18.0 \
djangosaml2==1.5.8 \
python-ldap==3.4.4 \
sqlalchemy==2.0.27

RUN find /pip-deps -name "__pycache__" -type d -exec rm -r {} + && \
    rm -rf /pip-deps/pip /pip-deps/wheel /pip-deps/setuptools

FROM python:3.10.13-alpine3.18

RUN apk add --no-cache \
bash \
socat \
jpeg \
zlib \
freetype \
lcms2 \
openjpeg \
tiff \
tk \
mariadb-dev \
libmemcached \
netcat-openbsd \
gcompat \
openldap

COPY --from=pip /pip-deps /usr/local/lib/python3.10/site-packages
COPY --from=get /tmp/seafile-server*/seahub /opt/seafile/seafile-server-latest/seahub
COPY --from=get /tmp/seafile-server*/runtime /opt/seafile/seafile-server-latest/runtime
COPY --from=get /tmp/seafile-server*/seahub.sh /opt/seafile/seafile-server-latest/seahub.sh
COPY --from=get /tmp/seafile-server*/check_init_admin.py /opt/seafile/seafile-server-latest/check_init_admin.py
COPY --from=get /tmp/seafile-server*/seafile/lib/python3/site-packages /opt/seafile/seafile-server-latest/seafile/lib/python3/site-packages
COPY --from=get /tmp/seafile-server*/pro/python/seafevents /opt/seafile/seafile-server-latest/pro/python/seafevents

COPY scripts /scripts
RUN chmod u+x /scripts/*

RUN mkdir -p /opt/seafile/logs &&\
touch /opt/seafile/logs/seahub.log &&\
mkdir -p /opt/seafile/pids

ENV PYTHONPATH=/usr/local/lib/python3.10/site-packages:/opt/seafile/seafile-server-latest/seahub/thirdpart:/opt/seafile/seafile-server-latest/seafile/lib/python3/site-packages:/opt/seafile/seafile-server-latest/seahub:/opt/seafile/seafile-server-latest/pro/python
ENV CCNET_CONF_DIR=/opt/seafile/conf/ccnet
ENV SEAFILE_CONF_DIR=/opt/seafile/seafile-data
ENV SEAFILE_CENTRAL_CONF_DIR=/opt/seafile/conf
ENV SEAFILE_RPC_PIPE_PATH=/opt/seafile/seafile-server-latest/runtime
ENV INNER_FILE_SERVER_ROOT=http://seafile-server:8082
ENV SEAHUB_LOG_DIR=/opt/seafile/logs
ENV SEAFILE_ADMIN_EMAIL=me@example.com
ENV SEAFILE_ADMIN_PASSWORD=asecret
ENV SEAFILE_SERVER_HOSTNAME=seafile-server
ENV PYTHON=python3
ENV SEAHUB_DIR=/opt/seafile/seafile-server-latest/seahub

EXPOSE 8000

CMD ["/scripts/start.sh"]
