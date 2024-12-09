#!/bin/bash

cd /root/infra

git pull

docker stack deploy --detach=true web -c docker/web.yml
docker stack deploy --detach=true webtop -c docker/webtop.yml
docker stack deploy --detach=true plex -c docker/plex.yml
docker stack deploy --detach=true cloudflared -c docker/cloudflared.yml
docker stack deploy --detach=true paperless -c docker/paperless.yml
docker stack deploy --detach=true registry -c docker/registry.yml
docker stack deploy --detach=true runner -c docker/runner.yml
