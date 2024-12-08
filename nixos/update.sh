#!/bin/bash

cd /root/repo

git pull

nixos-rebuild switch
