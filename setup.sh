#!/bin/bash

set -e

: ${MONSTER_UI_VERSION:=3.22}
: ${JQ_VERSION:=1.5}


echo "Setting up locales ..."
apt-get update -y
apt-get install -y locales

sed -ir '/en_US\.UTF-8 UTF-8/s/# //' /etc/locale.gen
echo 'LANG="en_US.UTF-8"'> /etc/default/locale

dpkg-reconfigure --frontend=noninteractive locales

update-locale LC_ALL='en_US.UTF-8'
update-locale LANG='en_US.UTF-8'
update-locale LANGUAGE='en_US.UTF-8'


echo "Creating monsterui home directory ..."
mkdir -p ~ /var/www/html


echo "Installing dependencies ..."
apt-get install -y \
    vim \
    curl \
    git


echo "Installing monster-ui ..."
cd /var/www/html
	git clone https://github.com/2600hz/monster-ui -b $MONSTER_UI_VERSION

	echo "Installing monster-ui apps ..."
	cd monster-ui/apps
		git clone https://github.com/2600hz/monster-ui-callflows callflows -b $MONSTER_UI_VERSION
		git clone https://github.com/2600hz/monster-ui-voip voip -b $MONSTER_UI_VERSION
		git clone https://github.com/2600hz/monster-ui-pbxs pbxs -b $MONSTER_UI_VERSION
		git clone https://github.com/2600hz/monster-ui-accounts accounts -b $MONSTER_UI_VERSION
		git clone https://github.com/2600hz/monster-ui-webhooks webhooks -b $MONSTER_UI_VERSION
		git clone https://github.com/2600hz/monster-ui-numbers numbers -b $MONSTER_UI_VERSION
		git clone https://github.com/siplabs/monster-ui-apiexplorer apiexplorer
		cd ~


echo "Adding highlight.js and clipboard.js to require.config paths ..."
sed -ir "/paths/a \
	\                'hljs': 'apps\/apiexplorer\/lib\/highlight\.pack',\n                'clipboard': 'apps\/apiexplorer\/lib\/clipboard\.min'," \
	/var/www/html/monster-ui/js/main.js

echo "Adding Handlebars to apiexplorer's app.js require's ..."
sed "/[(]'jqueryui'[)],/a \
    \                Handlebars = require('handlebars')," \
    /var/www/html/monster-ui/apps/apiexplorer/app.js

cat /var/www/html/monster-ui/js/config.js


echo "Writing .bashrc ..."
tee ~/.bashrc <<'EOF'
#!/bin/bash

TERM=xterm-256color
COLS=80
LINES=64

c_rst='\[\e[0m\]'
c_c='\[\e[36m\]'
c_g='\[\e[92m\]'
PS1="[${c_c}\u${c_rst}@\$(hostname) ${c_g}\W${c_rst}] $ "
LS_COLORS='rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lz4=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.webm=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.axv=38;5;13:*.anx=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.axa=38;5;45:*.oga=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:'

: ${LC_ALL:=en_US.utf8}
: ${LANG:=en_US.utf8}
: ${LANGUAGE:=en_US.utf8}

export TERM COLS LINES LS_COLORS PS1 LC_ALL LANG LANGUAGE

alias ls='ls --color'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
EOF


echo "Setting Ownership & Permissions ..."
chown -R nginx:nginx ~ /var/www/html/monster-ui

chmod -R 0755 /var/www/html/monster-ui
chmod +x ~/.bashrc /usr/local/bin/jq


echo "Cleaning up ..."
apt-get clean
rm -r /tmp/setup.sh





# : ${KAZOO_RELEASE:=R15B}


# echo -e "Creating user and group for bigcouch ..."
# groupadd monsterui
# useradd --home-dir ~ --shell /bin/bash --comment 'monsterui user' -g monsterui --create-home monsterui

# mkdir -p ~/bin


# echo "Setting locale ..."
# echo 'SUPPORTED="en_IN.utf8:en_IN:en_US.UTF-8:en_US:en"' >> /etc/sysconfig/i18n
# echo 'LANGUAGE="en_US.UTF-8"' >> /etc/sysconfig/i18n
# echo 'LC_ALL="en_US.UTF-8"' >> /etc/sysconfig/i18n


# echo "Adding 2600hz repo ..."
# tee /etc/yum.repos.d/2600hz.repo <<EOF
# [2600hz_base_staging]
# name=2600hz-$releasever - Base Staging
# baseurl=http://repo.2600hz.com/Staging/CentOS_6/x86_64/Base/
# gpgcheck=0
# enabled=1

# [2600hz_R15B_staging]
# name=2600hz-$releasever - ${KAZOO_RELEASE} Staging
# baseurl=http://repo.2600hz.com/Staging/CentOS_6/x86_64/${KAZOO_RELEASE}/
# gpgcheck=0
# enabled=1
# EOF


# echo "Installing Apache ..."
# yum -y update
# yum -y install httpd


# echo "Creating apache directories ..."
# mkdir -p /var/run/httpd


# echo "Fixing logs for docker ..."
# sed -ri 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g;' /etc/httpd/conf/httpd.conf

# # Disable directory listings
# sed -ri 's/ Indexes / -Indexes /g' /etc/httpd/conf/httpd.conf




# echo "Installing Monster-ui ..."
# yum -y install monster-ui*


# echo "Installing extras ..."
# yum -y install bind-utils git

# echo "Installing JQ ..."
# curl -o /usr/local/bin/jq -sSL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
# chmod +x /usr/local/bin/jq


# echo "Installing api-explorer ..."
# cd /var/www/html/monster-ui/apps
# 	git clone https://github.com/siplabs/monster-ui-apiexplorer apiexplorer

# echo "Adding highlight.js and clipboard.js to require.config paths ..."
# sed -ir 's/\(config:\"js\/config\",\)/\1hljs:\"apps\/apiexplorer\/lib\/highlight\.pack\",clipboard:\"apps\/apiexplorer\/lib\/clipboard\.min\",/' /var/www/html/monster-ui/js/main.js

# echo "Adding Handlebars to apiexplorer's app.js require's ..."
# sed -ir "/[(]'jqueryui'[)],/a \
#     \                Handlebars = require('handlebars')," /var/www/html/monster-ui/apps/apiexplorer/app.js



# # In the future, install other monster-ui components here #


# echo "Writing Hostname override fix ..."
# tee /usr/local/bin/hostname-fix <<'EOF'
# #!/bin/bash

# fqdn() {
# 	local IP=$(/bin/hostname -i | sed 's/\./-/g')
# 	local DOMAIN='default.pod.cluster.local'
# 	echo "${IP}.${DOMAIN}"
# }

# short() {
# 	local IP=$(/bin/hostname -i | sed 's/\./-/g')
# 	echo $IP
# }

# ip() {
# 	/bin/hostname -i
# }

# if [[ "$1" == "-f" ]]; then
# 	fqdn
# elif [[ "$1" == "-s" ]]; then
# 	short
# elif [[ "$1" == "-i" ]]; then
# 	ip
# else
# 	short
# fi
# EOF
# chmod +x /usr/local/bin/hostname-fix

# echo "Writing .bashrc ..."
# tee ~/.bashrc <<'EOF'
# #!/bin/bash

# if [ "$KUBERNETES_HOSTNAME_FIX" == true ]; then
# 	export HOSTNAME=$(hostname -f)
# fi
# EOF
# chown apache:apache ~/.bashrc


# echo "Setting Ownership & Permissions ..."

# # /etc/httpd
# chown -R apache:apache /etc/httpd 
# chmod -R 0755 /etc/httpd

# # /etc/httpd/conf
# find /etc/httpd/conf -type f -exec chmod 0644 {} \;
# find /etc/httpd/conf -type d -exec chmod 0700 {} \;

# # /etc/httpd/conf.d
# find /etc/httpd/conf.d -type f -exec chmod 0644 {} \;
# find /etc/httpd/conf.d -type d -exec chmod 0700 {} \;

# # /var/log/httpd
# chown -R apache:apache /var/log/httpd
# chmod -R 0770 /var/log/httpd

# # /usr/lib64/httpd
# chown -R apache:apache /usr/lib64/httpd
# chmod -R 0755 /usr/lib64/httpd

# # /var/www
# chown -R apache:apache /var/www
# chown -R 0755 /var/www

# # /var/run/httpd
# chown -R apache:apache /var/run/httpd
# chmod -R 0755 /var/run/httpd

# # /var/www/html/monster-ui
# chown -R apache:apache /var/www/html/monster-ui
# chmod -R 0755 /var/www/html/monster-ui


# echo "Cleaning up ..."
# yum clean all
# rm -r /tmp/setup.sh
