#!/bin/sh
# Sync local eepm to epm-sisyphus (eepm-bot directory, not touching system eepm)

rsync -av --delete \
    /srv/lav/Projects/git/eepm/ epm@epm-sisyphus:eepm-bot/
