#!/bin/sh
docker run --privileged --rm -i -t -v "$PWD:/data" libguestfs \
    virt-rescue -a /data/ubuntu-16.04.img
