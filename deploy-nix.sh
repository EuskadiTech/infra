#!/bin/bash

cd /root/infra

git pull

nixos-rebuild switch
