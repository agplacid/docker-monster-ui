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
    git clone -b $MONSTER_UI_BRANCH --single-branch --depth 1 https://github.com/2600hz/monster-ui monster-ui
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

                echo "Downloading pdf's from 2600hz ..."
                curl -sSL -o Editable.LOA.Form.pdf \
                    http://ui.zswitch.net/Editable.LOA.Form.pdf
                curl -sSL -o Editable.Resporg.Form.pdf \
                    http://ui.zswitch.net/Editable.Resporg.Form.pdf
                chmod 0777 *.pdf

                echo "Rewriting config to be more easily parsable in entrypoint ..."
                sed -i '/default:/s/ \/\/.*$//' js/config.js
                sed -i '\|provisioner:|s|// |// ,|' $_
                sed -i '\|socket:|s|// |// ,|' $_
                sed -i "\|socket:|i \                        //   with TLS: wss://blackhole-url \\
                        //   without TLS: ws://blackhole-url" $_
                sed -i "\|socket:|a \\
                        \\
                        // If you want to use the webphone, you will need to enable websockets in kamailio \\
                        // and plug the websocket uri in below: \\
                        //   with TLS: wss://kamailio-url:5065 \\
                        //   without TLS: ws://kamailio-url:5064 \\
                        // ,socketWebphone: 'wss://kamailio-url:5065'" $_
                sed -i '\|phonebook:|s|// |// ,|' $_
                sed -i '/resellerId:/s/,$//' $_
                sed -i '\|disableBraintree:|s|//[[:space:]]*||;/disableBraintree:/s/,$//' $_
                sed -i '/whitelabel:/s/^\([[:space:]]*\)\b/\1,/' $_
                sed -i '\|logoutTimer:|s|//[[:space:]]*||;/logoutTimer:/s/,$//' $_
                sed -i '\|language:|s|//[[:space:]]*|// ,|;/language:/s/,$//' $_
                sed -i '\|applicationTitle:|s|^\([[:space:]]*\)\b|\1,|;/applicationTitle:/s/,$//' $_
                sed -i '\|callReportEmail:|s|^\([[:space:]]*\)\b|\1,|;/callReportEmail:/s/,$//' $_
                sed -i '\|companyName:|s|^\([[:space:]]*\)\b|\1,|;/companyName:/s/,$//' $_
                sed -i '/nav:/s/^\([[:space:]]*\)\b/\1,/' $_
                sed -i '/help:/s/,$//' $_
                sed -i '\|logout:|s|^\([[:space:]]*\)// \b|\1,|;/logout:/s/,$//' $_
                sed -i '/loa:/s/,$//' $_
                sed -i '/preventDIDFormatting:/s/,$//' $_
                sed -i '/jiraFeedback/s/^\([[:space:]]*\)\b/\1,/' $_
                sed -i '\|resporg:|s|^\([[:space:]]*\)\b|\1,|;/resporg:/s/,$//' $_
                sed -i '/to enabled/s/\(enabled\):/\1/' $_
                sed -i '/enabled:/s/,$//' $_
                sed -i '\|url:|s|^\([[:space:]]*\)\b|\1,|;/url:/s/,$//' $_
                sed -i '\|showSmartPBXCallflows:|s|^\([[:space:]]*\)// \b|\1|;/showSmartPBXCallflows:/s/,$//' $_
                sed -i '\|showJSErrors:|s|^\([[:space:]]*\)// \b|\1,|;/showJSErrors:/s/,$//' $_


echo "Removing npm & gulp ..."
npm uninstall -g npm gulp
rm -rf ~/.{npm,v8*} /tmp/npm*


echo "Cleaning up unneeded packages ..."
apt-get purge -y --auto-remove \
    ca-certificates \
    curl \
    git \
    nodejs

rm -f /etc/apt/sources.list.d/nodesource.list


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
