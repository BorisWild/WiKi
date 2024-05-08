#!/bin/bash

#execute the script
#make it executable
#chmod 775 basicscript.sh
#./basicscript.sh
#or just
#bash basicscript.sh

echo "Install docker-compose"
echo "run with SUDO"

if ! systemctl -q is-active docker; then
	echo "No Docker installed..."
	exit 1	
fi

echo "Input release version: (ex: 2.5.0)"
echo "See: https://github.com/docker/compose/releases"
read version

if ! [ -z $version ] && [[ $version =~ ^[0-9\.]+$ ]]; then

	curl -L "https://github.com/docker/compose/releases/download/v${version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

	chmod +x /usr/local/bin/docker-compose

	docker-compose --version
else
	echo "Wrong version. Must be a number."
	exit 1	
fi




