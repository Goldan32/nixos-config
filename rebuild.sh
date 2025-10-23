#!/usr/bin/env bash

if [ "$1" == "" ]; then
    echo "rebuild.sh <target>"
    exit 1
fi

PROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
HOME_CONFIG="$PROOT/home"
DOTFILES="$PROOT/home/dotfiles"
TARGET="$1"

sudo nixos-rebuild switch --flake "$PROOT"#"$TARGET" --override-input home-config path:"$HOME_CONFIG" --override-input dotfiles "$DOTFILES"
