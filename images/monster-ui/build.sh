#!/bin/bash -l

set -e

# Use local cache proxy if it can be reached, else nothing.
eval $(detect-proxy enable)

build::user::create $USER

log::m-info "Installing $APP repo ..."
build::apt::add-key 7BD9BF62
echo -e 'deb http://nginx.org/packages/debian/ stretch nginx' > \
    /etc/apt/sources.list.d/nginx.list
apt-get -qq update


log::m-info "Installing $APP ..."
apt-get install -yqq curl nginx


# mkdir -p /tmp/monster-ui
# pushd $_
#     curl -LO https://github.com/telephoneorg/monster-ui-builder/releases/download/v$MONSTER_UI_TAG/monster-ui-debs-all.tar.gz
#     tar xzvf monster-ui*.tar.gz
#     dpkg -i *.deb
#     popd && rm -rf $OLDPWD


# log::m-info "Cleaning up unneeded packages ..."
# apt-get purge -y --auto-remove ca-certificates


log::m-info "Installing python3 ..."
apt-get install -yqq python3 python3-pip
# vendor version of pip becomes broken by newer requests, need to upgrade both
# vendor version of six 1.8.0 doesn't support the api being used by pykube
pip3 install --upgrade pip requests six setuptools


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
/etc/default/monster-ui* true $USER 644 755
/var/cache/nginx true $USER 755 755
/var/log/nginx true $USER 755 755
EOF


log::m-info "Setting Ownership & Permissions ..."
chown -R $USER:$USER \
    ~ \
    /usr/share/nginx \
    /etc/default/nginx* \
    /var/cache/nginx \
    /var/log/nginx

# chmod -R 0755 /var/www/html/monster-ui


log::m-info "Cleaning up ..."
apt-clean --aggressive

# if applicable, clean up after detect-proxy enable
eval $(detect-proxy disable)

rm -r -- "$0"
