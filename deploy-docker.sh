#!/bin/bash

cd /root/infra

git pull

docker stack deploy web -c docker/web.yml
docker stack deploy webtop -c docker/webtop.yml
docker stack deploy plex -c docker/plex.yml
docker stack deploy cloudflared -c docker/cloudflared.yml
