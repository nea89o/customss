#!/usr/bin/env bash

SCREENSHOT_PATH="$HOME/.lastfullss"
OUTPUT_PATH="$HOME/Pictures/Screenshots/$(date +'%Y-%m-%d %H:%M:%S').png"
grim -c - >"$SCREENSHOT_PATH"
CROP="$(slurp -I "$SCREENSHOT_PATH" | sed -r 's/([0-9]+),([0-9]+) ([0-9]+)x([0-9]+)/\3x\4+\1+\2/')"
magick convert png:- -crop "$CROP" png:- <"$SCREENSHOT_PATH" |tee "$OUTPUT_PATH" | wl-copy

