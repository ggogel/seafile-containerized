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

RUN sed -i "s@.*INNER_FILE_SERVER_ROOT.*@INNER_FILE_SERVER_ROOT = os.environ.get('INNER_FILE_SERVER_ROOT')@" /tmp/seafile-server-${SEAFILE_VERSION}/seahub/seahub/settings.py

RUN sed -i '/warning_if_seafile_not_running;/d' /tmp/seafile-server-${SEAFILE_VERSION}/seahub.sh

FROM alpine:3.20.3 AS clean

ENV SEAFILE_VERSION=11.0.13

COPY --from=build /tmp/seafile-server-${SEAFILE_VERSION} /tmp/seafile-server-${SEAFILE_VERSION}

RUN rm -rf /tmp/seafile-server-${SEAFILE_VERSION}/seahub/thirdpart

FROM python:3.10.15-alpine3.20 AS pip

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
future==1.0.0 \
pillow==11.0.0 \
captcha==0.6.0 \
pyjwt==2.9.0 \
mysqlclient==2.2.6 \
django==4.2.17 \
django-pylibmc==0.6.1 \
django-simple-captcha==0.6.0 \
pycryptodome==3.21.0 \
djangosaml2==1.9.3 \
python-ldap==3.4.4 \
sqlalchemy==2.0.36 \
sqlalchemy==2.0.36 \
django-statici18n==2.5.0 \
django_webpack_loader==3.1.1 \
django_picklefield==3.2 \
django_formtools==2.5.1 \
djangorestframework==3.15.2 \
python-dateutil==2.9.0.post0 \
python-cas==1.6.0 \
requests==2.32.3 \
requests_oauthlib==2.0.0 \
qrcode==8.0 \
chardet==5.2.0 \
openpyxl==3.1.5 \
Markdown==3.7 \
bleach==6.2.0 \
pypinyin==0.53.0 \
PyMuPDF==1.24.14 \
pymysql==1.1.1

RUN find /pip-deps -name "__pycache__" -type d -exec rm -r {} + && \
    rm -rf /pip-deps/pip /pip-deps/wheel /pip-deps/setuptools

FROM python:3.10.15-alpine3.20

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
COPY --from=clean /tmp/seafile-server*/seahub /opt/seafile/seafile-server-latest/seahub
COPY --from=clean /tmp/seafile-server*/runtime /opt/seafile/seafile-server-latest/runtime
COPY --from=clean /tmp/seafile-server*/seahub.sh /opt/seafile/seafile-server-latest/seahub.sh
COPY --from=clean /tmp/seafile-server*/check_init_admin.py /opt/seafile/seafile-server-latest/check_init_admin.py
COPY --from=clean /tmp/seafile-server*/seafile/lib/python3/site-packages /opt/seafile/seafile-server-latest/seafile/lib/python3/site-packages
COPY --from=clean /tmp/seafile-server*/pro/python/seafevents /opt/seafile/seafile-server-latest/pro/python/seafevents
COPY --from=build /tmp/seafile-server*/seahub/thirdpart/bin /opt/seafile/seafile-server-latest/seahub/thirdpart/bin
COPY --from=build /tmp/seafile-server*/seahub/thirdpart/gunicorn /opt/seafile/seafile-server-latest/seahub/thirdpart/gunicorn 
COPY --from=build /tmp/seafile-server*/seahub/thirdpart/registration /opt/seafile/seafile-server-latest/seahub/thirdpart/registration
COPY --from=build /tmp/seafile-server*/seahub/thirdpart/constance /opt/seafile/seafile-server-latest/seahub/thirdpart/constance
COPY --from=build /tmp/seafile-server*/seahub/thirdpart/termsandconditions /opt/seafile/seafile-server-latest/seahub/thirdpart/termsandconditions
COPY --from=build /tmp/seafile-server*/seahub/thirdpart/seafobj /opt/seafile/seafile-server-latest/seahub/thirdpart/seafobj

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