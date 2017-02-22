# Monster-UI (stable) w/ Kubernetes manifests

[![Build Status](https://travis-ci.org/sip-li/docker-monsterui.svg?branch=master)](https://travis-ci.org/sip-li/docker-monsterui) [![Docker Pulls](https://img.shields.io/docker/pulls/callforamerica/monsterui.svg)](https://hub.docker.com/r/callforamerica/monsterui) [![Size/Layers](https://images.microbadger.com/badges/image/callforamerica/monsterui.svg)](https://microbadger.com/images/callforamerica/monsterui)

## Maintainer
Joe Black | <joe@valuphone.com> | [github](https://github.com/joeblackwaslike)


## Description
Minimal image with jinja templates rendered by tmpld.  This image uses a custom version of Debian Linux (Jessie) that I designed weighing in at ~22MB compressed.


## Build Environment
Build environment variables are often used in the build script to bump version numbers and set other options during the docker build phase.  Their values can be overridden using a build argument of the same name.
* `MONSTERUI_VERSION`
* `MONSTER_UI_BRANCH`
* `MONSTER_APPS_VERSION`
* `MONSTER_APPS_BRANCH`
* `MONSTER_APPS`
* `MONSTER_APP_APIEXPLORER_BRANCH`
* `NGINX_VERSION`
* `NODE_VERSION`
* `TMPLD_VERSION`

[todo] Finish describing these.


The following variables are standard in most of our dockerfiles to reduce duplication and make scripts reusable among different projects:
* `APP`: monsterui
* `USER`: monsterui
* `HOME` /opt/monsterui


## Run Environment
Run environment variables are used in the [entrypoint](entrypoint) script to render configuration templates, perform flow control, etc.  These values can be overridden when inheriting from the base dockerfile, specified during `docker run`, or in kubernetes manifests in the `env` array.


### Templates
All environment variables in this image are used in the following templates in the [build/templates](build/templates) directory of this repo.


#### config.js:
* `MONSTERUI_ROOT_DOMAIN`
* `MONSTERUI_COMPANY_NAME`
* `MONSTERUI_CROSSBAR_URI`
* `MONSTERUI_PROVISIONER_URI`
* `MONSTERUI_WEBSOCKET_URI`
* `MONSTERUI_WEBPHONE_URI`
* `MONSTERUI_KAZOO_CLUSTER_ID`
* `MONSTERUI_RESELLER_ID`
* `MONSTERUI_DISABLE_BRAINTREE`
* `MONSTERUI_LOGOUT_TIMER`
* `MONSTERUI_ADDITIONAL_LOGGED_IN_APPS`
* `MONSTERUI_ADDITIONAL_CSS_FILES`
* `MONSTERUI_LANGUAGE`
* `MONSTERUI_APPLICATION_TITLE`
* `MONSTERUI_CALL_REPORT_EMAIL`
* `MONSTERUI_COMPANY_NAME`
* `MONSTERUI_SUPPORT_URL`
* `MONSTERUI_LOGOUT_URL`
* `MONSTERUI_LOA_URI`
* `MONSTERUI_RESPORG_URI`
* `MONSTERUI_PREVENT_DID_FORMATTING`
* `MONSTERUI_JIRA_FEEDBACK_URL`
* `MONSTERUI_SHOW_ALL_CALLFLOWS`
* `MONSTERUI_SHOW_JS_ERRORS`


#### monsterui.conf:
* `NGINX_PROXY_PROTOCOL`
* `NGINX_LOAD_BALANCER_CIDR`
* `NGINX_CACHING`


#### nginx.conf:
* `NGINX_LOG_LEVEL`
* `NGINX_HTTP_CLIENT_MAX_BODY_SIZE`

[todo] Finish describing these.


## Usage
### Under docker (pre-built)
All of our docker-* repos in GitHub have CI pipelines that push to docker cloud/hub.  

This image is available at:
* [https://store.docker.com/community/images/callforamerica/monsterui](https://store.docker.com/community/images/callforamerica/monsterui)
*  [https://hub.docker.com/r/callforamerica/monsterui](https://hub.docker.com/r/callforamerica/monsterui).

* `docker pull callforamerica/monsterui`

To run:

```bash
docker run -d \
    --name monsterui \
    -h monsterui.local \
    -p "80:80" \
    -e "NGINX_PROXY_PROTOCOL=false" \
    -e "NGINX_LOG_LEVEL=warn" \
    -e "MONSTERUI_CROSSBAR_URI=http://localhost:8000/v2/" \
    -e "MONSTERUI_WEBSOCKET_URI=ws://localhost:5555" \
    -e "MONSTERUI_WEBPHONE_URI=ws://localhost:5064" \
    -e "MONSTERUI_DISABLE_BRAINTREE=false" \
    -e "MONSTERUI_SHOW_JS_ERRORS=true" \
    callforamerica/monsterui
```

**NOTE:** Please reference the `Run Environment` section for the list of available environment variables, edit to your individual needs.


### Under docker-compose
Pull the images
```bash
docker-compose pull
```

Start application and dependencies
```bash
# start in foreground
docker-compose up --abort-on-container-exit

# start in background
docker-compose up -d
```


### Under Kubernetes
Edit the manifests under `kubernetes/<environment>` to reflect your specific environment and configuration.

Deploy monsterui:
```bash
kubectl create -f kubernetes/<environment>
```

**NOTE:** Ensure kazoo deployment is running.  This container will be paused by the kubewait init-container until it's service dependencies exist and all pass readiness-checks.
