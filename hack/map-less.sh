#!/bin/bash
sed -e 's/VoidSymbol/-/g' "$@" | tr -s ' ' '\t' | column -s $'\t' -t | less -S
