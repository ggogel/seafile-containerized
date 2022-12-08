FROM alpine:3.16.3 AS get
ENV SEAFILE_SERVER=seafile-server SEAFILE_VERSION=9.0.10

RUN apk add --no-cache wget

RUN cd /tmp && \
    wget https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    tar -zxvf seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz && \
    rm -f seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

RUN sed -i "s@.*INNER_FILE_SERVER_ROOT.*@INNER_FILE_SERVER_ROOT = os.environ.get('INNER_FILE_SERVER_ROOT')@" /tmp/seafile-server-${SEAFILE_VERSION}/seahub/seahub/settings.py

RUN sed -i '/warning_if_seafile_not_running;/d' /tmp/seafile-server-${SEAFILE_VERSION}/seahub.sh

FROM python:3.11.1-alpine3.16 AS pip

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
libmemcached-dev

RUN python3 -m pip install --upgrade pip &&\
pip3 install --timeout=3600 \
future \
pillow \
captcha \
pyjwt \
mysqlclient \
django==3.2.16 \
django-pylibmc \
django-simple-captcha \
pycryptodome==3.12.0 \
&& rm -r /root/.cache/pip

FROM python:3.11.1-alpine3.16

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
gcompat

COPY --from=get /tmp/seafile-server*/seahub /opt/seafile/seafile-server-latest/seahub
COPY --from=get /tmp/seafile-server*/runtime /opt/seafile/seafile-server-latest/runtime
COPY --from=get /tmp/seafile-server*/seahub.sh /opt/seafile/seafile-server-latest/seahub.sh
COPY --from=get /tmp/seafile-server*/check_init_admin.py /opt/seafile/seafile-server-latest/check_init_admin.py
COPY --from=get /tmp/seafile-server*/seafile/lib/python3/site-packages /opt/seafile/seafile-server-latest/seafile/lib/python3/site-packages
COPY --from=pip /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY scripts /scripts

RUN chmod u+x /scripts/*
RUN mkdir -p /opt/seafile/logs &&\
touch /opt/seafile/logs/seahub.log &&\
mkdir -p /opt/seafile/pids

ENV PYTHONPATH=/usr/local/lib/python3.8/site-packages:/opt/seafile/seafile-server-latest/seahub/thirdpart:/opt/seafile/seafile-server-latest/seafile/lib/python3/site-packages:/opt/seafile/seafile-server-latest/seahub
ENV CCNET_CONF_DIR=/opt/seafile/conf/ccnet
ENV SEAFILE_CONF_DIR=/opt/seafile/seafile-data
ENV SEAFILE_CENTRAL_CONF_DIR=/opt/seafile/conf
ENV SEAFILE_RPC_PIPE_PATH=/opt/seafile/seafile-server-latest/runtime
ENV INNER_FILE_SERVER_ROOT=http://seafile-server:8082
ENV SEAHUB_LOG_DIR=/opt/seafile/logs
ENV SEAFILE_ADMIN_EMAIL=me@example.com
ENV SEAFILE_ADMIN_PASSWORD=asecret
ENV PYTHON=python3

EXPOSE 8000

CMD ["/scripts/start.sh"]