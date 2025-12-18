#!/bin/sh

CONFIG_DIR="$HOME/.config"

sync_dir() {
    src="$1"
    dest="$CONFIG_DIR/$1"

    rsync -a --itemize-changes "$src/" "$dest/" \
        | awk '/^[><]f/ {
            print $2 " has been modified!"
        }'
}

sync_dir hypr
sync_dir waybar
sync_dir wofi
sync_dir dunst
sync_dir kitty

echo "Install complete"
