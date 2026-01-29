#!/bin/sh

CONFIG_DIR="$HOME/.config"
WATCH_MODE=0

# Enable watch mode if --watch is passed
if [ "$1" = "--watch" ]; then
  WATCH_MODE=1
fi

sync_dir() {
  src="$1"
  dest="$CONFIG_DIR/$1"

  # Capture rsync output
  changes=$(rsync -a --itemize-changes "$src/" "$dest/" \
    | awk '/^[><]f/ { print $2 }')

  if [ -n "$changes" ]; then
    echo "$changes" | while read -r file; do
      echo "$file has been modified!"
    done
    return 0
  else
    return 1
  fi
}

sync_all() {
  changed=0

  for dir in hypr waybar wofi dunst kitty; do
    if sync_dir "$dir"; then
      changed=1
    fi
  done

  if [ "$changed" -eq 0 ]; then
    echo "No files changed!"
  fi
}

# Initial sync
sync_all
echo "Install complete"

# Watch mode
if [ "$WATCH_MODE" -eq 1 ]; then
  echo "Watching for changes..."
  inotifywait -m -r -e modify,create,delete,move \
    hypr waybar wofi dunst kitty |
  while read -r _; do
    sync_all
  done
fi
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
