# monsterui (stable) w/ Kubernetes fixes & manifests

[![Build Status](https://travis-ci.org/sip-li/docker-monsterui.svg?branch=master)](https://travis-ci.org/sip-li/docker-monsterui) [![Docker Pulls](https://img.shields.io/docker/pulls/callforamerica/monsterui.svg)](https://store.docker.com/community/images/callforamerica/monsterui)

## Maintainer

Joe Black <joeblack949@gmail.com>

## Description

Minimal image with <features>.  This image uses a custom version of Debian Linux (Jessie) that I designed weighing in at ~22MB compressed.

## Build Environment

<!-- The build environment has been split off from this repo and now lives @ [https://github.com/sip-li/kazoo-builder](https://github.com/sip-li/kazoo-builder).  See the README.md file there for more details on the build environment. -->

Build environment variables are often used in the build script to bump version numbers and set other options during the docker build phase.  Their values can be overridden using a build argument of the same name.

* `ERLANG_VERSION`
* `MONSTERUI_VERSION`

The following variables are standard in most of our dockerfiles to reduce duplication and make scripts reusable among different projects:

* `APP`: monsterui
* `USER`: monsterui
* `HOME` /opt/monsterui


## Run Environment

Run environment variables are used in the entrypoint script to render configuration templates, perform flow control, etc.  These values can be overridden when inheriting from the base dockerfile, specified during `docker run`, or in kubernetes manifests in the `env` array.

* `MONSTERUI_LOG_LEVEL`: lowercased and used as the value for the log_level in `monsterui.conf`.  Defaults to `info`.
* `MONSTERUI_`: used as the value for `` in the `` section of ``.  Defaults to ``.
* `MONSTERUI_`: used as the value for `` in the `` section of ``.  Defaults to ``.
* `MONSTERUI_`: used as the value for `` in the `` section of ``.  Defaults to ``.
* `MONSTERUI_`: used as the value for `` in the `` section of ``.  Defaults to ``.
* `MONSTERUI_`: `,`'s are replaced with ` `'s and fed as positional arguments to `monsterui command` before starting monsterui.  Defaults to `monsterui-`.


## Usage


### Under docker (pre-built)

All of our docker-* repos in github have CI pipelines that push to docker cloud/hub.  

This image is available at:
* [https://store.docker.com/community/images/callforamerica/monsterui](https://store.docker.com/community/images/callforamerica/monsterui)
*  [https://hub.docker.com/r/callforamerica/monsterui](https://hub.docker.com/r/callforamerica/monsterui).

and through docker itself: `docker pull callforamerica/monsterui`

To run:

```bash
docker run -d \
    --name monsterui \
    -h monsterui.local \
    callforamerica/monsterui
```

**NOTE:** Please reference the Run Environment section for the list of available environment variables.


### Under Kubernetes

Edit the manifests under `kubernetes/` to reflect your specific environment and configuration.

Create a secret for the erlang cookie:
```bash
kubectl create secret generic erlang-cookie --from-literal=erlang.cookie=$(LC_ALL=C tr -cd '[:alnum:]' < /dev/urandom | head -c 64)
```

Create a secret for the monsterui credentials:
```bash
kubectl create secret generic monsterui-creds --from-literal=monsterui.user=$(sed $(perl -e "print int rand(99999)")"q;d" /usr/share/dict/words) --from-literal=monsterui.pass=$(LC_ALL=C tr -cd '[:alnum:]' < /dev/urandom | head -c 32)
```

Deploy monsterui:
```bash
kubectl create -f kubernetes
```


## Issues

**ref:**  [https://github.com/sip-li/docker-monsterui/issues](https://github.com/sip-li/docker-monsterui/issues)
