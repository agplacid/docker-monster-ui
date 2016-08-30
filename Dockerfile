FROM    nginx

MAINTAINER joe <joe@valuphone.com>

LABEL   os="linux" \
        os.distro="debian" \
        os.version="jessie"

LABEL   image.name="monsterui" \
        image.version="3.22"

ENV     MONSTER_UI_VERSION=3.22

ENV     HOME=/opt/monsterui
ENV     PATH=$HOME:$PATH

COPY    setup.sh /tmp/setup.sh
RUN     /tmp/setup.sh

COPY    nginx.conf /etc/nginx/nginx.conf

COPY    entrypoint /usr/bin/entrypoint

ENV     NGINX_LOG_LEVEL=info

ENV     CROSSBAR_URI=https://api.valuphone.com:8443
        
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

CMD     ["/usr/bin/entrypoint"]
