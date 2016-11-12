#!/bin/sh
SSH_GUEST='ssh -o NoHostAuthenticationForLocalhost=yes -i ./ssh/id_rsa -p 2222 root@localhost'

printf '\033[36m%s\033[0m\n' "+ Starting up virtual machine..."
./hack/run.sh -display none -daemonize

printf '\033[36m%s\033[0m\n' "+ Waiting for SSH..."
for i in 1 2 3 4 5 6 7 8 9 10; do
    $SSH_GUEST 'uname -a' && break
    sleep 2
done

printf '\033[36m%s\033[0m\n' "+ Generate dump of keymaps using system kbd..."
tar zc bin hack keymaps | $SSH_GUEST '
TMPDIR=$(mktemp -d -t kbd-test.XXXXXXXX)
cd "$TMPDIR"
tar zx --warning=no-unknown-keyword

./hack/dump-keymaps.sh
tar zc dump

cd /
rm -rf "$TMPDIR"
shutdown -h now
' | tar zx
