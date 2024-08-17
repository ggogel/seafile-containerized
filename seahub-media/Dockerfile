FROM ubuntu:jammy@sha256:adbb90115a21969d2fe6fa7f9af4253e16d45f8d4c1e930182610c4731962658 AS build

RUN apt-get update && \
    apt-get install -y software-properties-common wget && \
    add-apt-repository ppa:longsleep/golang-backports

ENV SEAFILE_VERSION=11.0.12

WORKDIR /tmp
RUN wget https://raw.githubusercontent.com/haiwen/seafile-docker/master/build/seafile-build.sh
RUN wget https://raw.githubusercontent.com/haiwen/seafile-docker/master/build/seafile-build.py
RUN chmod +x ./seafile-build.sh
RUN ./seafile-build.sh ${SEAFILE_VERSION}

FROM caddy:2.8.4-alpine

COPY --from=build /tmp/seafile-server*/seahub/media /usr/share/caddy/media