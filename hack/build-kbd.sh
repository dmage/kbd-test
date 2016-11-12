#!/bin/sh -efu
docker build -f ./hack/Dockerfile.kbd -t kbd .
docker run --rm -i -t \
        -v "$KBDROOT:/kbdroot" \
        kbd \
    sh -c 'set -e; [ -e ./Makefile ] || { ./autogen.sh; ./configure; }; make'
