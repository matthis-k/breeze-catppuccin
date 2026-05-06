#!/usr/bin/env bash

set -euo pipefail

IFS=$'\n\t'

if [[ ! -d ".git" && ! -d "Breeze-Catppuccin" && ! -f "install.sh" ]]; then
    if ! command -v git &>/dev/null; then
        echo "error: \`git\` not found"

        exit 1
    fi

    git clone https://github.com/matthis-k/breeze-catppuccin.git

    cd breeze-catppuccin/
fi

if ! command -v nix &>/dev/null; then
    echo "error: \`nix\` not found"

    exit 1
fi

nix build .#build

mkdir -p ~/.local/share/icons
rm -rf ~/.local/share/icons/Breeze-Catppuccin-*
cp -r result/share/icons/* ~/.local/share/icons/
