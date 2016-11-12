#!/bin/sh
qemu-system-x86_64 -m 1024 -drive file=ubuntu-16.04.img,format=raw,if=virtio -netdev user,id=user.0,hostfwd=tcp:127.0.0.1:2222-:22 -net nic,netdev=user.0 "$@"
