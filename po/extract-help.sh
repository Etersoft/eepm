#!/bin/sh
# Extract HELPCMD/HELPOPT/HELPSHORT strings from code for translation
# Output: pot-format entries

cd "$(dirname "$0")/.."

grep -rh "# HELP\(CMD\|OPT\|SHORT\):" bin pack.d play.d repack.d 2>/dev/null | \
    sed -e 's/.*# HELP\(CMD\|OPT\|SHORT\): *//' | \
    sort -u | \
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        # Escape quotes and backslashes for pot format
        escaped=$(printf '%s' "$line" | sed 's/\\/\\\\/g; s/"/\\"/g')
        echo "#: help-string"
        echo "msgid \"$escaped\""
        echo "msgstr \"\""
        echo
    done
