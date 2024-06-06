[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ggogel/seafile-server?label=docker%20build%3A%20seafile-server%20)](https://hub.docker.com/r/ggogel/seafile-server)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ggogel/seafile-server?label=docker%20build%3A%20seafile-server%20)](https://hub.docker.com/r/ggogel/seafile-server)
[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/ggogel/seafile-server/latest)](https://hub.docker.com/r/ggogel/seafile-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/ggogel/seafile-server)](https://hub.docker.com/r/ggogel/seafile-server)

[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ggogel/seahub?label=docker%20build%3A%20seahub)](https://hub.docker.com/r/ggogel/seahub)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ggogel/seahub?label=docker%20build%3A%20seahub)](https://hub.docker.com/r/ggogel/seahub)
[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/ggogel/seahub/latest)](https://hub.docker.com/r/ggogel/seahub)
[![Docker Pulls](https://img.shields.io/docker/pulls/ggogel/seahub)](https://hub.docker.com/r/ggogel/seahub)

[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ggogel/seahub-media?label=docker%20build%3A%20seahub-media)](https://hub.docker.com/r/ggogel/seahub-media)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ggogel/seahub-media?label=docker%20build%3A%20seahub-media)](https://hub.docker.com/r/ggogel/seahub-media)
[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/ggogel/seahub/latest)](https://hub.docker.com/r/ggogel/seahub-media)
[![Docker Pulls](https://img.shields.io/docker/pulls/ggogel/seahub-media)](https://hub.docker.com/r/ggogel/seahub-media)

[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ggogel/seafile-caddy?label=docker%20build%3A%20seafile-caddy)](https://hub.docker.com/r/ggogel/seafile-caddy)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ggogel/seafile-caddy?label=docker%20build%3A%20seafile-caddy)](https://hub.docker.com/r/ggogel/seafile-caddy)
[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/ggogel/seafile-caddy/latest)](https://hub.docker.com/r/ggogel/seafile-caddy)
[![Docker Pulls](https://img.shields.io/docker/pulls/ggogel/seafile-caddy)](https://hub.docker.com/r/ggogel/seafile-caddy)


# Containerized Seafile Deployment
A fully containerized deployment of Seafile for Docker, Docker Swarm and Kubernetes.

## Table of Contents
1. [Features](#features)
1. [Structure](#structure)
1. [Getting Started](#getting-started)
1. [Additional Information](#additional-information)

## Features
- Complete redesign of the [official Docker deployment](https://manual.seafile.com/docker/deploy%20seafile%20with%20docker/) with containerization best-practices in mind.
- Runs seahub (frontend) and seafile server (backend) in separate containers, which commuicate with each other over TCP.
- Cluster without pro edition.
- Separate Caddy container as reverse proxy
- Increased Security:
    - The caddy reverse proxy serves as a single entry point to the stack. Everything else runs in an isolated network.
    - Using [Alpine Linux](https://alpinelinux.org/about/) based images for the frontend, which is designed with security in mind and comes with proactive security features.
    - Official Seafile Docker deployment uses entirely outdated base images and dependencies. Here base images and dependencies are updated regularly.
- Reworked Dockerfiles featuring multi-stage builds, allowing for smaller images and faster builds.
- Schedule offline garbage collection with cron job.
- Runs upgrade scripts automatically when a new image version is deployed.
- All features of Seafile Community Edition are included.

## Structure

Services:
- *seafile-server*
    - contains the backend component called [seafile-server](https://github.com/haiwen/seafile-server)
    - handles storage, some direct client access and seafdav
- *seahub*
    - dynamic frontend component called [seahub](https://github.com/haiwen/seahub)
    - serves the web-ui
    - communicates with seafile-server
- *seahub-media*
    - serves static website content as well as avatars and custom logos
- *db*
    - the database used by *seafile-server* and *seahub*
- *memcached*
    - database cache for *seahub*
- *seafile-caddy*
    - reverse proxy that forwards paths to the correct endpoints: *seafile-server*, *seahub* or *seahub-media*
    - is the single external entry point to the deployment

Volumes:

- *seafile-data*
    - shared data volume of *seafile-server* and *seahub*
    - also contains configuration and log files
- *seafile-mariadb*
    - volume of the *db* service
    - stores the database
- *seahub-custom*
    - contains custom logos
    - stored by *seahub* and served by *seahub-media*
- *seahub-avatars*
    - contains user avatars
    - stored by *seahub* and served by *seahub-media*

*Note: In the official docker deployment custom and avatars are served by nginx. Seahub alone cannot serve them for some reason, hence the separate volumes.*

Networks:
- *seafile-net*
    - isolated local network used by the services to communicate with each other

## Getting Started

1. ***Prerequisites***

    Requires Docker and docker-compose to be installed.

    For deployment on Kubernetes see [Wiki / Kubernetes](https://github.com/ggogel/seafile-containerized/wiki/Kubernetes).

    For additional considerations when using Docker in Swarm Mode see [Wiki / Docker Swarm](https://github.com/ggogel/seafile-containerized/wiki/Docker-Swarm).

3. ***Get the compose file***
    
    Use this compose file as a starting point.
    ```
    wget https://raw.githubusercontent.com/ggogel/seafile-containerized/master/compose/docker-compose.yml
    ```
   
4. ***Set environment variables***

    **Important:** The environment variables are only relevant for the first deployment. The existing configuration in the volumes is **not** overwritten.

    On a first deployment, you need to carefully set those values. Changing them later can be tricky. Please take a look at the Seafile documentation on how to change configuration values.
   
    ### *seafile-server*
    The name of the mariadb service, which is automatically the docker-internal hostname.
     ```
    - DB_HOST=db 
     ```
    Password of the mariadb root user. This must equal MYSQL_ROOT_PASSWORD.
     ```
    - DB_ROOT_PASSWD=db_dev
     ```
    Time zone used by Seafile.
     ```
    - TIME_ZONE=Europe/Berlin
     ```
   
    This will be used for the SERVICE_URL and FILE_SERVER_ROOT. 
    Important: Changing those values in the config files later won't have any effect because they are written to the database. Those values have priority over the config files. To change them enter the "System Admin" section on the web-ui. If you encounter issues with file upload, those are likely misconfigured.
     ```
    - SEAFILE_URL=seafile.mydomain.com 
     ```
    If you plan to use a reverse proxy with https, set this to true. This will replace http with https in the SERVICE_URL and FILE_SERVER_ROOT.
     ```
    - HTTPS=false
     ```

    ### *seahub*
    Username / E-Mail of the first admin user.
     ```
    - SEAFILE_ADMIN_EMAIL=me@example.com
     ```
    Password of the first admin user.
     ```
    - SEAFILE_ADMIN_PASSWORD=asecret
     ```

    ### *db*
    Password of the mariadb root user. Must match DB_ROOT_PASSWD.
     ```
    - MYSQL_ROOT_PASSWORD=db_dev
     ```
    Enable logging console.
     ```
    - MYSQL_LOG_CONSOLE=true
    ```

4. ***(Optional) Reverse Proxy***
    
    The caddy reverse proxy integrated with the deployment exposes **port 80**. Point your existing reverse proxy to that port.
    
    This deployment does by design **not** include a reverse proxy capable of HTTPS and Let's Encrypt, unlike the official deployment, because usually Docker users already have some docker-based reverse proxy solution deployed, which does exactly that.
    
5. ***Deployment***
    
    #### Docker Compose
    After you followed the above steps and have configured everything correctly run:
    ```
    docker-compose -p seafile up -d
    ```
    #### Docker Swarm
    After you followed the above steps and have configured everything correctly run:
    ```
    docker stack deploy -c docker-compose.yml seafile
    ```
## Advanced Configuration and Troubleshooting

For advanced configuration and troubleshooting see the [Wiki](https://github.com/ggogel/seafile-containerized/wiki). If you encounter a bug or have a feature request, please feel free to open an issue.

This project supports only Compose Specification-compatible tools such as `docker compose`, `podman compose`, and `nerdctl compose`, as well as Kubernetes. Deployment methods that do not fully comply with these standards, such as `podman quadlet` or `podman play`, are not supported. Currently, these tools run all containers in the same pod, which creates an entirely different networking structure. Please avoid opening issues related to them.
