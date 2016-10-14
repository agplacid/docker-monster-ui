FROM    callforamerica/debian

MAINTAINER joe <joe@valuphone.com>

ARG     MONSTER_UI_VERSION
ARG     MONSTER_UI_BRANCH
ARG     MONSTER_APPS_VERSION
ARG     MONSTER_APPS_BRANCH
ARG     MONSTER_APPS
ARG     MONSTER_APP_APIEXPLORER_BRANCH
ARG     NGINX_VERSION
ARG     NODE_VERSION=6
ARG     JQ_VERSION

ENV     NGINX_VERSION=${NGINX_VERSION:-1.10.0} \
        MONSTER_UI_VERSION=${MONSTER_UI_VERSION:-4.0} \
        MONSTER_UI_BRANCH=${MONSTER_UI_BRANCH:-master} \
        MONSTER_APPS_VERSION=${MONSTER_APPS_VERSION:-4.0} \
        MONSTER_APPS_BRANCH=${MONSTER_APPS_BRANCH:-master} \
        MONSTER_APPS=${MONSTER_APPS:-callflows,voip,pbxs,accounts,webhooks,numbers} \
        MONSTER_APP_APIEXPLORER_BRANCH=${MONSTER_APP_APIEXPLORER_BRANCH:-master} \
        NODE_VERSION=${NODE_VERSION:-6} \
        JQ_VERSION=${JQ_VERSION:-1.5}

LABEL   app.nginx.version=$NGINX_VERSION
LABEL   app.monsterui-version=$MONSTER_UI_VERSION \
        app.monsterui-branch=$MONSTER_UI_BRANCH

LABEL   app.monster-apps.version=$MONSTER_APPS_VERSION \
        app.monster-apps.branch=${MONSTER_APPS_BRANCH} \
        app.monster-apps.apps="${MONSTER_APPS},apiexplorer"

ENV     HOME=/opt/monsterui

COPY    build.sh /tmp/
RUN     /tmp/build.sh

COPY    nginx.conf /etc/nginx/
COPY    entrypoint /

ENV     NGINX_LOG_LEVEL=info

ENV     CROSSBAR_URI=https://api.valuphone.com

ENV     ENABLE_SMARTPBX_CALLFLOWS=true \
        DISABLE_BRAINTREE=false \
        ENABLE_PROVISIONER=false

ENV     COMPANY_NAME=Valuphone \
        APPLICATION_TITLE=Valuphone \
        CALL_REPORT_EMAIL=support@valuphone.com

EXPOSE  80

VOLUME  ["/var/www/html"]

# USER    monsterui

WORKDIR /opt/monsterui

ENTRYPOINT  ["/dumb-init", "--"]
CMD         ["/entrypoint"]
