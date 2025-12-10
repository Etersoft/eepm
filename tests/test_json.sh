#!/bin/sh

# ["version"]
get_json_value()
{
    local field="$1"
    echo "$field" | grep -q -E "^\[" || field='["'$field'"]'
    # TODO: use grep and escape []
    epm tool json -b | grep -m1 -F "$field" | sed -e 's|.*\][[:space:]]||' | sed -e 's|"\(.*\)"|\1|g'
}

get_json_values()
{
    local field="$1"
    echo "$field" | grep -q -E "^\[" || field="\[$(echo "$field" | sed 's/[^ ]*/"&"/g' | sed 's/ /,/g'),[0-9]*\]"
    epm tool json -b | grep "^$field" | sed -e 's|.*[[:space:]]||' | sed -e 's|"\(.*\)"|\1|g'
}

# ["version"]	"0.48.8"
# ["downloadUrl"]	"https://downloads.cursor.com/production/7801a556824585b7f2721900066bc87c4a09b743/linux/arm64/Cursor-0.48.8-aarch64.AppImage"
# ["rehUrl"]	"https://cursor.blob.core.windows.net/remote-releases/7801a556824585b7f2721900066bc87c4a09b743/vscode-reh-linux-arm64.tar.gz"

cat <<EOF | get_json_value "downloadUrl"
{"version":"0.48.8","downloadUrl":"https://downloads.cursor.com/production/7801a556824585b7f2721900066bc87c4a09b743/linux/arm64/Cursor-0.48.8-aarch64.AppImage","rehUrl":"https://cursor.blob.core.windows.net/remote-releases/7801a556824585b7f2721900066bc87c4a09b743/vscode-reh-linux-arm64.tar.gz"}
EOF

print_test_json()
{
cat <<EOF
{
    "name": "kde",
    "version": "6.4.5",
    "installed": false,
    "dependencies": [ "plasma-desktop", "lightdm", "lightdm-kde-greeter", "plasma-discover", "power-profiles-daemon", "qt6-wayland", "wayland-utils", "vulkan-tools"],
    "description": "KDE Plasma is a powerful desktop environment with support for X11 and Wayland",
    "metapackages": [ "kde" ]
}
EOF
}

echo "=== name"
echo "@$(print_test_json | get_json_value "name")@"
echo "=== version"
echo "@$(print_test_json | get_json_value "version")@"
echo "=== installed"
echo "@$(print_test_json | get_json_value "installed")@"
echo "=== dependencies"
print_test_json | get_json_values "dependencies" | xargs
echo "=== metapackages"
print_test_json | get_json_values "metapackages"
echo "=== description"
print_test_json | get_json_value "description"
echo "==="
print_test_json | epm tool json -b
