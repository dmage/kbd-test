#!/bin/sh
SSH_GUEST='ssh -o NoHostAuthenticationForLocalhost=yes -i ./id_rsa -p 2222 root@localhost'

printf '\033[36m%s\033[0m\n' "+ Starting up virtual machine..."
qemu-system-x86_64 -m 1024 -drive file=ubuntu-16.04.img,format=raw,if=virtio -netdev user,id=user.0,hostfwd=tcp:127.0.0.1:2222-:22 -net nic,netdev=user.0 -display none -daemonize "$@"

printf '\033[36m%s\033[0m\n' "+ Waiting for SSH..."
for i in 1 2 3 4 5 6 7 8 9 10; do
    $SSH_GUEST 'uname -a' && break
    sleep 2
done

printf '\033[36m%s\033[0m\n' "+ Generate dump of keymaps using system kbd..."
tar zc keymaps | $SSH_GUEST '
#!/bin/ash -efu
void_keymap() {
  printf "keymaps 0\n"
  seq 1 255 | sed -e "s/.*/keycode & =/"
}

do_dump() {
  local outdir="$1"
  mkdir -p "./$outdir"
  find ./keymaps -type f -name "*.map" | sed -e "s#./keymaps/##" | while read -r f; do
    n=$(printf "%s" "$f" | tr -c "A-Za-z0-9.-" "_")
    void_keymap | loadkeys -c -s >/dev/null
    if loadkeys "./keymaps/$f" >/dev/null 2>"./$outdir/$n"; then
      dumpkeys -f >>"./$outdir/$n"
    else
      echo "please check $outdir/$n" >&2
    fi
  done
  echo "OK $outdir" >&2
}

TMPDIR=$(mktemp -d -t kbd-test.XXXXXXXX)
cd "$TMPDIR"
tar zx --warning=no-unknown-keyword

kbd_mode -u
do_dump dump/unicode
kbd_mode -a
do_dump dump/8bit
tar zc dump

cd /
rm -rf "$TMPDIR"
shutdown -h now
' | tar zx
