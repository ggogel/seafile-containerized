FROM ubuntu:jammy@sha256:d80997daaa3811b175119350d84305e1ec9129e1799bba0bd1e3120da3ff52c3 AS build

RUN apt-get update && \
    apt-get install -y software-properties-common wget && \
    add-apt-repository ppa:longsleep/golang-backports

ENV SEAFILE_VERSION=11.0.13

WORKDIR /tmp
RUN wget https://raw.githubusercontent.com/haiwen/seafile-docker/master/build/seafile-build.sh
RUN wget https://raw.githubusercontent.com/haiwen/seafile-docker/master/build/seafile-build.py
RUN chmod +x ./seafile-build.sh
RUN ./seafile-build.sh ${SEAFILE_VERSION}

FROM caddy:2.8.4-alpine

COPY --from=build /tmp/seafile-server*/seahub/media /usr/share/caddy/media