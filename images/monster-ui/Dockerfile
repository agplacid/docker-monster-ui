FROM telephoneorg/debian:stretch

MAINTAINER Joe Black <me@joeblack.nyc>

ARG     MONSTER_UI_TAG
ARG     MONSTER_APPS
ARG     NGINX_VERSION
ARG     NODE_VERSION
ARG     TMPLD_VERSION

ENV     MONSTER_UI_TAG=${MONSTER_UI_TAG:-4.1}
ENV     MONSTER_APPS ${MONSTER_APPS:-accounts,callflows,fax,numbers,pbxs,voip,voicemails,webhooks}
ENV     NODE_VERSION ${NODE_VERSION:-6}
ENV     TMPLD_VERSION ${TMPLD_VERSION:-0.2.3}

LABEL   app.kazoo.monster-ui.core.tag=$MONSTER_UI_TAG
LABEL   app.kazoo.monster-ui.apps.list=$MONSTER_APPS
LABEL   app.tmpld.version=$TMPLD_VERSION

ENV     APP monster-ui
ENV     USER $APP
ENV     HOME /opt/$APP

COPY    build.sh /tmp/
RUN     /tmp/build.sh

COPY    entrypoint /
COPY    templates /templates

ENV     NGINX_LOG_LEVEL warn
ENV     NGINX_HTTP_CLIENT_MAX_BODY_SIZE 30M
ENV     MONSTERUI_CROSSBAR_URI //localhost:8000/v2/
# ENV     MONSTERUI_WEBSOCKET_URI wss://wss.host.com
# ENV     MONSTERUI_WEBPHONE_URI wss://wss.host.com:5065
ENV     MONSTERUI_DISABLE_BRAINTREE true
ENV     MONSTERUI_SHOW_ALL_CALLFLOWS true
ENV     MONSTERUI_SHOW_JS_ERRORS false

EXPOSE  80

VOLUME  ["/var/www/html"]

WORKDIR $HOME

SHELL       ["/bin/bash"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD curl -f -s http://localhost:80 || exit 1

ENTRYPOINT  ["/dumb-init", "--"]
CMD         ["/entrypoint"]
