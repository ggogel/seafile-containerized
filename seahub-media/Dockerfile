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

FROM caddy:2.8.4-alpine

COPY --from=build /tmp/seafile-server*/seahub/media /usr/share/caddy/media