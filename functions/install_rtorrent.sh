#!/bin/sh
# ===================================================================
# Title			: install_rtorrent.sh
# Description	: Helper function to install rTorrent & ruTorrent on 
#               + Nginx
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================
install_rtorrent_rutorrent () {
	step=$((step+1)); substep=a

	echo "${BU}"$step". Installing rTorrent...${NC}"
	cd /tmp/

    # Install PHP 7.2
	echo "${LB}        "$substep")${NC} Installing dependencies" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --quiet
    wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm --quiet
    rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm --quiet

    yum install -y yum-utils & >/dev/null 2>&1; spinner
    yum-config-manager --enable remi-php72 & >/dev/null 2>&1; spinner
	
	#Install required packages
	echo "${LB}        "$substep")${NC} Installing rTorrent" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm 2>&1

	yum install -y libtool screen nginx php php-fpm php-cli php-curl php-geoip php-xmlrpc mediainfo rtorrent >/dev/null 2>&1; spinner
 
	[ -d "/var/www/html/" ] && cd /var/www/html/ || { mkdir -p /var/www/html/; cd /var/www/html; }
	
	echo "${LB}        "$substep")${NC} Installing ruTorrent" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	git clone https://github.com/Novik/ruTorrent.git rutorrent --quiet &; spinner
	cd rutorrent/plugins/
	git clone https://github.com/xombiemp/rutorrentMobile.git mobile --quiet &; spinner
	cd /tmp/
	
	echo "${BU}Step "$step" complete.${NC}"
	echo ""
}

configure_nginx_rutorrent () {
	step=$((step+1)); substep=a
	echo "${BU}"$step". Configuring Nginx and downloading server block for ruTorrent...${NC}"
		
    mkdir /etc/nginx/sites-available /etc/nginx/sites-enabled	
	mv nginx.conf nginx.conf.default
    wget https://raw.githubusercontent.com/IFeelFine/Media-Server-Installer/master/config/nginx/nginx.conf --quiet
    
	wget https://raw.githubusercontent.com/IFeelFine/Media-Server-Installer/master/config/nginx/sites-available/rutorrent.conf --quiet -P /etc/nginx/sites-available/
	
	echo "${YB}ruTorrent user information${NC}"	
	read -t 10 -p "What will be the username to access to ruTorrent? [rutorrent]" rutorrent_user_temp
	[ -z "$rutorrent_user_temp" ] && rutorrent_user="rutorrent"	|| rutorrent_user=$(echo "$rutorrent_user_temp" | tr -s '[:upper:]' '[:lower:]')		
	read -t 10 -p "What will be $rutorrent_user_temp's password? [rutorrent]" rutorrent_password
	[ -z "$rutorrent_password" ] && rutorrent_password="rutorrent"
	
	sed -i 's/rutorrent_user/'$rutorrent_user'/g' /etc/nginx/sites-available/rutorrent.conf
		
	htpasswd -b -c /var/www/html/rutorrent/.htpasswd $rutorrent_user $rutorrent_password >/dev/null 2>&1
	chmod 400 /var/www/html/rutorrent/.htpasswd
				
	echo "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	systemctl restart nginx && systemctl is-enabled $service_name || systemctl enable nginx
	systemctl restart php-fpm && systemctl is-enabled $service_name || systemctl enable php-fpm
		
	echo "${BU}Step "$step" complete.${NC}"
	echo ""
}
	
configure_user_rtorrent_rutorrent () {
	step=$((step+1)); substep=a
	echo "${BU}"$step". Configuring "$rutorrent_user" user for rTorrent and ruTorrent...${NC}"
		
	useradd $rutorrent_user
	[ -d "/home/$rutorrent_user/" ] || mkdir -p /home/$rutorrent_user/
	mkdir /home/$rutorrent_user/torrents /home/$rutorrent_user/watch /home/$rutorrent_user/.session
	tee /home/$rutorrent_user/.rtorrent.rc 2>&1 >/dev/null << EOF 
scgi_port = 127.0.0.1:5001
encoding_list = UTF-8
port_range = 45000-65000
port_random = no
check_hash = no
directory = /home/$rutorrent_user/torrents
session = /home/$rutorrent_user/.session
encryption = allow_incoming, try_outgoing, enable_retry
schedule = watch_directory,1,1,\"load_start=/home/$rutorrent_user/watch/*.torrent\"
schedule = untied_directory,5,5,\"stop_untied=/home/$rutorrent_user/watch/*.torrent\"
use_udp_trackers = yes
dht = on
peer_exchange = yes
min_peers = 40
max_peers = 100
min_peers_seed = 10
max_peers_seed = 100
max_uploads = 15
execute = {sh,-c,/usr/bin/php /var/www/html/rutorrent/php/initplugins.php $rutorrent_user &}
schedule = espace_disque_insuffisant,1,30,close_low_diskspace=10240M" 
EOF

	chown -R $rutorrent_user: /home/$rutorrent_user/
			
	mkdir /var/www/html/rutorrent/conf/users/$rutorrent_user/ 
	tee /var/www/html/rutorrent/conf/users/$rutorrent_user/config.php 2>&1 >/dev/null << EOF 
<?php
\$pathToExternals['curl'] = '/usr/bin/curl';
\$topDirectory = '/home/$rutorrent_user';
\$scgi_port = 5001;
\$scgi_host = '127.0.0.1';
\$XMLRPCMountPoint = '/$rutorrent_user';" >
EOF
		
	echo "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	systemctl restart nginx
		
	echo "${BU}Step "$step" complete.${NC}"
	echo ""
}

configure_rtorrent_service () {
	step=$((step+1)); substep=a
	echo "${BU}"$step". Configuring rTorrent service..."

	echo "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    tee /usr/lib/systemd/system/rtorrent.service 2>&1 >/dev/null << EOF
[Unit]
Description=rTorrent Service
After=network.target

[Service]
Type=forking
KillMode=none
ExecStart=/usr/bin/screen -d -m -fa -S rtorrent /usr/bin/rtorrent
ExecStop=/usr/bin/killall -w -s 2 /usr/bin/rtorrent
WorkingDirectory=/home/$rutorrent_user
User=$rutorrent_user
Group=$rutorrent_user

[Install]
WantedBy=multi-user.target
EOF
    
	# Enable and start the Service
    systemctl is-active $service_name || systemctl start $service_name
    systemctl is-active $service_name && { systemctl is-enabled $service_name || systemctl enable $service_name || { echo "Failed to start and enable the $service_name service. Exiting...";  exit 1; } }

	echo "${BU}Step "$step" complete.${NC}"
	echo ""
}