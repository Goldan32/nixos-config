#!/usr/bin/env bash

if [ "$1" == "" ]; then
    echo "rebuild.sh <target>"
    exit 1
fi

PROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
TARGET="$1"

sudo nixos-rebuild switch --flake "$PROOT"#"$TARGET"
