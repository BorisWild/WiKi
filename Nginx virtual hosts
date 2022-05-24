#!/bin/bash

#execute the script
#make it executable
#chmode 775 basicscript.sh
#./basicscript.sh
#or just
#bash basicscript.sh

echo "Create Virtual Host in Nginx."

if ! systemctl -q is-active nginx; then
	echo "Nginx is down..."
	exit 1	
fi

if ! systemctl -q is-active docker; then
	echo "Docker is down..."
	exit 1	
fi

if ! [ -d /etc/nginx/sites-available ]; then
	echo "No /etc/nginx/sites-available"
	exit 1	
fi

if ! [ -d /etc/nginx/sites-enabled ]; then
	echo "No /etc/nginx/sites-enabled"
	exit 1	
fi	

echo "Input local domain: (ex: site1.example.com)"
read domain

echo "Create on Localhost? y/n" 
read isLocalhost
if [ isLocalhost=="y" ]; then
	echo "Writing to /etc/hosts"
	echo "127.0.0.1	$domain" >> /etc/hosts	
fi

touch "/etc/nginx/sites-available/${domain}.conf"

echo "Using Docker? y/n"
read isDocker
if [ isDocker=="y" ]; then
echo "Input container Port:"
read port
echo "Docker networks:"
docker network ls
echo "Input your network:"
read dockerNetwork
docker inspect $dockerNetwork
echo "Input container Ip:"
read containerIp
echo "server {
	listen 80;
	listen [::]:80;
	
	server_name ${domain};
	location / {
		proxy_pass http://${containerIp}:${port};
		proxy_buffering off;
		proxy_set_header X-Real-IP \$remote_addr;
	}
}" > "/etc/nginx/sites-available/${domain}.conf"

else

echo "Input path to site!"
echo "(ex: /path/to/project/example/public_html)"
read path

#chown -R www-data:www-data /path/to/project/example/public_html
echo "Input index file!"
echo "(ex: index.html index.htm)"
read indexFile

echo "server {
	listen 80;
	# Defines the domain or subdomain name. 
	server_name ${domain}
	
	# Root directory used to search for a file
	root ${path}
		
	# Defines the file to use as index page
	index ${indexFile}
		
	access_log /var/log/nginx/${domain}-access.conf
	error_log /var/log/nginx/${domain}-error.log

	location / {
	# Return a 404 error for instances when the server receives 
	# requests for untraceable files and directories.
			try_files \$uri \$uri/ =404;
	}
}" > "/etc/nginx/sites-available/${domain}.conf"

fi	

#check nginx configs
sudo nginx -t

echo "Making soft link to /etc/nginx/sites-enabled/"
ln -s /etc/nginx/sites-available/${domain}.conf /etc/nginx/sites-enabled/

echo "Restarting nginx..."
#service nginx reload
systemctl reload nginx

echo "Don't forget set up TLS/SSL on prod !"

echo "See http://${domain}"
