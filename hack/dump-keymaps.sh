#!/bin/sh -efu
LOADKEYS=loadkeys
if [ -x ./bin/loadkeys ]; then
    LOADKEYS=./bin/loadkeys
fi

DUMPKEYS=dumpkeys
if [ -x ./bin/dumpkeys ]; then
    DUMPKEYS=./bin/dumpkeys
fi


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

kbd_mode -u
do_dump dump/unicode dumper_flags_unicode

kbd_mode -a
do_dump dump/8bit dumper_flags_8bit
