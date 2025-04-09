#!/bin/sh

# ["version"]
parse_json_value()
{
    local field="$1"
    echo "$field" | grep -q -E "^\[" || field='["'$field'"]'
    epm tool json -b | grep -m1 -F "$field" | sed -e 's|.*[[:space:]]||' | sed -e 's|"\(.*\)"|\1|g'
}

# ["version"]	"0.48.8"
# ["downloadUrl"]	"https://downloads.cursor.com/production/7801a556824585b7f2721900066bc87c4a09b743/linux/arm64/Cursor-0.48.8-aarch64.AppImage"
# ["rehUrl"]	"https://cursor.blob.core.windows.net/remote-releases/7801a556824585b7f2721900066bc87c4a09b743/vscode-reh-linux-arm64.tar.gz"

cat <<EOF | parse_json_value "downloadUrl"
{"version":"0.48.8","downloadUrl":"https://downloads.cursor.com/production/7801a556824585b7f2721900066bc87c4a09b743/linux/arm64/Cursor-0.48.8-aarch64.AppImage","rehUrl":"https://cursor.blob.core.windows.net/remote-releases/7801a556824585b7f2721900066bc87c4a09b743/vscode-reh-linux-arm64.tar.gz"}
EOF
