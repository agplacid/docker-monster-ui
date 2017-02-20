#!/bin/bash -l

set -e

# Use local cache proxy if it can be reached, else nothing.
eval $(detect-proxy enable)

build::user::create $USER

log::m-info "Installing $APP repo ..."
build::apt::add-key 7BD9BF62
echo -e 'deb http://nginx.org/packages/debian/ jessie nginx\ndeb-src http://nginx.org/packages/debian/ jessie nginx' > \
    /etc/apt/sources.list.d/nginx.list
apt-get -q update


log::m-info "Installing essentials ..."
apt-get install -qq -y curl ca-certificates git


log::m-info "Installing $APP ..."
apt_nginx_vsn=$(build::apt::get-version nginx)

log::m-info "apt versions:  nginx: $apt_nginx_vsn"
apt-get install -qq -y nginx=$apt_nginx_vsn


log::m-info "Installing nodejs v$NODE_VERSION ..."
curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
apt-get install -yqq nodejs


log::m-info "Installing node packages ..."
npm install -g npm gulp


log::m-info "Installing monster-ui ..."
mkdir -p /var/www/html
pushd $_
    git clone -b $MONSTER_UI_BRANCH --single-branch --depth 1 \
        https://github.com/2600hz/monster-ui monster-ui
        pushd $_
            log::m-info  "Installing monster-ui apps ..."
            pushd src/apps
                for app in $(echo "${MONSTER_APPS//,/ }"); do
                    git clone -b $MONSTER_APPS_BRANCH --single-branch \
                        --depth 1 https://github.com/2600hz/monster-ui-${app} \
                        $app
                done
                git clone -b $MONSTER_APP_APIEXPLORER_BRANCH --single-branch \
                    --depth 1 https://github.com/siplabs/monster-ui-apiexplorer \
                    apiexplorer
                cd ..
                    sed -i "/paths/a \
                        \                'hljs': 'apps\/apiexplorer\/lib\/highlight\.pack',\n                'clipboard': 'apps\/apiexplorer\/lib\/clipboard\.min'," js/main.js
                    sed -i "/[(]'jqueryui'[)],/a \
                        \                Handlebars = require('handlebars')," apps/apiexplorer/app.js
                    popd
                npm install
                gulp build-prod

                npm uninstall
                find -mindepth 1 -maxdepth 1 -not -name dist -exec rm -rf {} \;
                mv dist/* .
                rm -rf dist

                log::m-info "Downloading pdf's from 2600hz ..."
                curl -sSL -o Editable.LOA.Form.pdf \
                    http://ui.zswitch.net/Editable.LOA.Form.pdf
                curl -sSL -o Editable.Resporg.Form.pdf \
                    http://ui.zswitch.net/Editable.Resporg.Form.pdf
                chmod 0777 *.pdf


log::m-info "Removing npm & gulp ..."
npm uninstall -g npm gulp
rm -rf ~/.{npm,v8*} /tmp/npm*


log::m-info "Cleaning up unneeded packages ..."
apt-get purge -y --auto-remove \
    ca-certificates \
    git \
    nodejs


log::m-info "Installing python3 ..."
apt-get install -yqq python3 python3-pip
# vendor version of pip becomes broken by newer requests, need to upgrade both
# vendor veresion of six 1.8.0 doesn't support the api being used by pykube
pip3 install --upgrade pip requests six


log::m-info "Installing tmpld ..."
pip3 install tmpld==$TMPLD_VERSION

log::m-info "Cleaning up unnecessary files ..."
rm -f /etc/init.d/nginx* \
    /etc/logrotate.d/nginx \
    /etc/nginx/conf.d/default.conf \
    /etc/apt/sources.list.d/nodesource.list


log::m-info "Adding fixattr files ..."
tee /etc/fixattrs.d/20-${APP}-perms <<EOF
/etc/default/nginx* true $USER 644 755
/etc/default/monsterui* true $USER 644 755
/var/cache/nginx true $USER 755 755
/var/log/nginx true $USER 755 755
EOF


log::m-info "Setting Ownership & Permissions ..."
chown -R $USER:$USER \
    ~ \
    /var/www/html \
    /usr/share/nginx \
    /etc/default/nginx* \
    /var/cache/nginx \
    /var/log/nginx

chmod -R 0755 /var/www/html/monster-ui


log::m-info "Cleaning up ..."
apt-clean --aggressive

# if applicable, clean up after detect-proxy enable
eval $(detect-proxy disable)

rm -r -- "$0"
