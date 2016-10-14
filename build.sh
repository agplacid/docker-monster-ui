#!/bin/bash

set -e

app=monsterui
user=$app


# Use local cache proxy if it can be reached, else nothing.
eval $(detect-proxy enable)


echo "Creating user and group for $user ..."
useradd --system --home-dir ~ --create-home --shell /bin/false --user-group $user


echo "Installing essentials ..."
apt-get update
apt-get install -y curl ca-certificates git


echo "Installing nginx repo ..."
curl -sSL http://nginx.org/keys/nginx_signing.key | apt-key add -
echo -e "deb http://nginx.org/packages/debian/ jessie nginx\ndeb-src http://nginx.org/packages/debian/ jessie nginx" > /etc/apt/sources.list.d/nginx.list
apt-get update


echo "Calculating versions ..."
apt_nginx_version=$(apt-cache show nginx | grep ^Version | grep $NGINX_VERSION | sort -n | head -1 | awk '{print $2}')
echo "nginx: $apt_nginx_version"


echo "Installing nginx ..."
apt-get install -y nginx=$apt_nginx_version


echo "Removing unnecessary files ..."
rm /etc/init.d/nginx* /etc/logrotate.d/nginx


echo "Installing nodejs v$NODE_VERSION ..."
curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
apt-get install -y nodejs


echo "Installing node packages ..."
npm install -g npm gulp


echo "Installing monster-ui ..."
mkdir -p /var/www/html
pushd $_
    git clone -b $MONSTER_APPS_BRANCH --single-branch --depth 1 https://github.com/2600hz/monster-ui monster-ui
        pushd $_
            echo "Installing monster-ui apps ..."
            pushd src/apps
                for app in $(echo "${MONSTER_APPS//,/ }")
                do
                    git clone -b $MONSTER_APPS_BRANCH --single-branch --depth 1 https://github.com/2600hz/monster-ui-${app} $app
                done
                git clone -b $MONSTER_APP_APIEXPLORER_BRANCH --single-branch --depth 1 https://github.com/siplabs/monster-ui-apiexplorer apiexplorer
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
                sed -i '/default:/s/ \/\/.*$//' js/config.js


echo "Removing npm & gulp ..."
npm uninstall -g npm gulp
rm -rf ~/.{npm,v8*} /tmp/npm*


echo "Cleaning up unneeded packages ..."
apt-get purge -y --auto-remove \
    ca-certificates \
    curl \
    git \
    nodejs


echo "Setting ownerships & permissions ..."
chown -R $user:$user \
    ~ \
    /var/www/html \
    /usr/share/nginx \
    /usr/share/doc/nginx \
    /usr/lib/nginx/modules \
    /etc/nginx \
    /etc/default/nginx* \
    /var/cache/nginx \
    /var/log/nginx

chmod -R 0755 /var/www/html/monster-ui

echo "Cleaning up ..."
apt-clean --aggressive

# if applicable, clean up after detect-proxy enable
eval $(detect-proxy disable)

rm -r -- "$0"
