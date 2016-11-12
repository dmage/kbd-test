#!/bin/sh -efu
docker build -q -f ./hack/Dockerfile.libguestfs -t libguestfs .
mkdir -p ./cache
docker run --privileged --rm -i -t \
        -v "$PWD:/data" \
        -v "$PWD/cache:/root/.cache/virt-builder" \
        libguestfs \
    virt-builder ubuntu-16.04 \
        -o ./ubuntu-16.04.img \
        --size 4G \
        --format raw \
        --no-network \
        --hostname localhost \
        --root-password password:qwerty \
        --ssh-inject root:file:./ssh/id_rsa.pub \
        --edit /etc/network/interfaces:s/ens2/ens3/ \
        --firstboot-command "dpkg-reconfigure openssh-server"
#qemu-img convert -f raw -O qcow2 ubuntu-16.04.img ubuntu-16.04.qcow2
