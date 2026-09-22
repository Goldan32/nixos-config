#!/usr/bin/env bash

set -e
PROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")"
HOME_CONFIG="$PROOT/home"

cd "$HOME_CONFIG" && \
    nix flake update

cd "$PROOT" && \
    nix flake update

echo "Update done, do a rebuild to take effect"
