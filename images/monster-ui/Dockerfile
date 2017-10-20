FROM telephoneorg/debian:stretch

MAINTAINER Joe Black <me@joeblack.nyc>

ARG     MONSTER_UI_BRANCH
ARG     MONSTER_APPS
ARG     MONSTER_APPS_BRANCH
ARG     MONSTER_APP_APIEXPLORER_BRANCH
ARG     NGINX_VERSION
ARG     NODE_VERSION
ARG     TMPLD_VERSION

ENV     MONSTER_UI_BRANCH ${MONSTER_UI_BRANCH:-4.2}
ENV     MONSTER_APPS ${MONSTER_APPS:-accounts,callflows,fax,numbers,pbxs,voip,voicemails,webhooks}
ENV     MONSTER_APPS_BRANCH ${MONSTER_APPS_BRANCH:-$MONSTER_UI_BRANCH}
ENV     MONSTER_APP_APIEXPLORER_BRANCH ${MONSTER_APP_APIEXPLORER_BRANCH:-master}
ENV     NODE_VERSION ${NODE_VERSION:-6}
ENV     TMPLD_VERSION ${TMPLD_VERSION:-0.2.3}

LABEL   app.kazoo.monster-ui.core.branch=$MONSTER_UI_BRANCH
LABEL   app.kazoo.monster-ui.apps.list="${MONSTER_APPS},apiexplorer"
LABEL   app.kazoo.monster-ui.apps.branch=$MONSTER_APPS_BRANCH
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
# ENV     MONSTERUI_CROSSBAR_URI //api.proxy-host/v2/
# ENV     MONSTERUI_WEBSOCKET_URI wss://wss.api.proxy-host.com
# ENV     MONSTERUI_WEBPHONE_URI wss://wss.proxy-host.com:5065
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
