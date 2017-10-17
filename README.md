# Monster-UI (stable) w/ Kubernetes manifests
[![Build Status](https://travis-ci.org/telephoneorg/docker-monster-ui.svg?branch=master)](https://travis-ci.org/telephoneorg/docker-monster-ui) [![Docker Pulls](https://img.shields.io/docker/pulls/telephoneorg/monster-ui.svg)](https://hub.docker.com/r/telephoneorg/monster-ui) [![Size/Layers](https://images.microbadger.com/badges/image/telephoneorg/monster-ui.svg)](https://microbadger.com/images/telephoneorg/monster-ui) [![Github Repo](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/telephoneorg/docker-monster-ui)


## Maintainer
Joe Black | <me@joeblack.nyc> | [github](https://github.com/joeblackwaslike)


## Description
Minimal image with jinja templates rendered by tmpld.  This image uses a custom, minimal version of Debian Linux.


## Build Environment
Build environment variables are often used in the build script to bump version numbers and set other options during the docker build phase.  Their values can be overridden using a build argument of the same name.
* `MONSTER_UI_BRANCH`
* `MONSTER_APPS_BRANCH`
* `MONSTER_APPS`
* `MONSTER_APP_APIEXPLORER_BRANCH`
* `NODE_VERSION`
* `TMPLD_VERSION`

[todo] Finish describing these.


The following variables are standard in most of our dockerfiles to reduce duplication and make scripts reusable among different projects:
* `APP`: monster-ui
* `USER`: monster-ui
* `HOME` /opt/monster-ui


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


#### monster-ui.conf:
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
* [https://store.docker.com/community/images/telephoneorg/monster-ui](https://store.docker.com/community/images/telephoneorg/monster-ui)
*  [https://hub.docker.com/r/telephoneorg/monster-ui](https://hub.docker.com/r/telephoneorg/monster-ui).

* `docker pull telephoneorg/monster-ui`

To run:

```bash
docker run -d \
    --name monster-ui \
    -p "80:80" \
    -e "NGINX_PROXY_PROTOCOL=false" \
    -e "NGINX_LOG_LEVEL=warn" \
    -e "MONSTERUI_CROSSBAR_URI=http://localhost:8000/v2/" \
    -e "MONSTERUI_WEBSOCKET_URI=ws://localhost:5555" \
    -e "MONSTERUI_WEBPHONE_URI=ws://localhost:5064" \
    -e "MONSTERUI_DISABLE_BRAINTREE=false" \
    -e "MONSTERUI_SHOW_JS_ERRORS=true" \
    telephoneorg/monster-ui
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

Deploy monster-ui:
```bash
kubectl create -f kubernetes/<environment>
```

**NOTE:** Ensure kazoo deployment is running.  This container will be paused by the kubewait init-container until it's service dependencies exist and all pass readiness-checks.
