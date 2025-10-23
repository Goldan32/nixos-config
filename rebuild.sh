#!/usr/bin/env bash

PROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
HOME_CONFIG="$PROOT/home"
DOTFILES="$PROOT/home/dotfiles"

sudo nixos-rebuild switch --flake "$PROOT"#server --override-input home-config path:"$HOME_CONFIG" --override-input dotfiles "$DOTFILES"
