#!/bin/sh -efu
if [ -z "${LOADKEYS-}" ]; then
    if [ -x ./bin/loadkeys ]; then
        LOADKEYS=./bin/loadkeys
    else
        LOADKEYS=loadkeys
    fi
fi

if [ -z "${DUMPKEYS-}" ]; then
    if [ -x ./bin/dumpkeys ]; then
        DUMPKEYS=./bin/dumpkeys
    else
        DUMPKEYS=dumpkeys
    fi
fi

: "${KBD_MODE=kbd_mode}"


void_keymap() {
    printf "keymaps 0\n"
    seq 0 255 | sed -e "s/.*/keycode & =/"
}

dumper_flags_unicode() {
    :
}

dumper_flags_8bit() {
    local keymap=$1
    sed -ne 's/^charset "\(.*\)"\( *#.*\)\?$/-c \1/p' "$keymap"
}

do_dump() {
    local outdir="$1"
    local dumper_flags="$2"
    mkdir -p "./$outdir"
    find ./keymaps -type f -name "*.map" | sed -e "s#./keymaps/##" | while read -r f; do
        n=$(printf "%s" "$f" | tr -c "A-Za-z0-9.-" "_")
        void_keymap | $LOADKEYS -c -s >/dev/null
        if $LOADKEYS "./keymaps/$f" >/dev/null 2>"./$outdir/$n"; then
            $DUMPKEYS -f $($dumper_flags "./keymaps/$f") >>"./$outdir/$n"
        else
            echo "please check $outdir/$n" >&2
        fi
    done
    echo "OK $outdir" >&2
}

(
printf "%s: " "$LOADKEYS"; $LOADKEYS -V
printf "%s: " "$DUMPKEYS"; $DUMPKEYS -V
) >&2

$KBD_MODE -u
do_dump dump/unicode dumper_flags_unicode

$KBD_MODE -a
do_dump dump/8bit dumper_flags_8bit
