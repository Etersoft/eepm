#!/bin/sh
# Sync local eepm to epm-update (eepm-bot directory, not touching system eepm)

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
rsync -av --delete \
    "$SCRIPT_DIR/" epm@epm-update:eepm-bot/
