#!/usr/bin/env bash

set -e
PROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")"
HOME_CONFIG="$PROOT/home"
DOTFILES="$PROOT/home/dotfiles"

cd "$HOME_CONFIG" && \
    nix flake update --override-input dotfiles path:"$DOTFILES"

cd "$PROOT" && \
    nix flake update --override-input home-config path:"$HOME_CONFIG"

echo "Update done, do a rebuild to take effect"

