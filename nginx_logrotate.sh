#!/bin/bash
# clean docker and log rotation on nginx logs in docker container

docker system prune -af  --filter "until=$((30*24))h"

#rm logs
/usr/bin/docker exec $(docker ps -q --filter "name=app") bash -c 'rm /var/log/nginx/*'
#recreate logs
/usr/bin/docker exec $(docker ps -q --filter "name=app") bash -c 'kill -USR1 $(cat /var/run/nginx.pid)'
