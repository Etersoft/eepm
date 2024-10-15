#!/bin/sh

DIR=play.d
LOG_FILE="process_log.txt"

extract_var() {
    grep -E "^$1=" "$2" | sed -E "s/^$1=(.*)/\1/" | tr -d '"' | tr -d "'"
}

extract_pkgurl() {
    if grep -q "^[^#]*get_github_url" "$1"; then
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/.*get_github_url[[:space:]]+([^[:space:]]+).*/\1/' | tr -d '"'
    elif grep -q "^[^#]*eget --list --latest" "$1"; then
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/.*eget --list --latest[[:space:]]+([^[:space:]]+).*/\1/' | tr -d '"'
    else
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/^PKGURL=(.*)/\1/' | tr -d '"'
    fi
}

extract_download_mask() {
    if grep -q "^[^#]*get_github_url" "$1"; then
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/.*get_github_url[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+).*/\1/' | sed 's/[)"]*$//' | tr -d '"'
    elif grep -q "^[^#]*eget --list --latest" "$1"; then
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/.*eget --list --latest[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+).*/\1/' | sed 's/[)"]*$//' | tr -d '"'
    else
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/^PKGURL=(.*)/\1/' | tr -d '"'
    fi
}

replace_vars() {
    local mask="$1"
    echo "$mask" | sed "s/\${PKGNAME}/$PKGNAME/g; s/\$PKGNAME/$PKGNAME/g; s/\${VERSION}/\*/g; s/\$VERSION/\*/g"
}

> "$LOG_FILE"

for SH_FILE in $DIR/*.sh; do
    if echo $SH_FILE | grep -q "common"; then
        echo "$SH_FILE пропущен: файл common" >> "$LOG_FILE"
        continue
    fi

    PKGNAME=$(extract_var PKGNAME $SH_FILE)
    PKGNAME=$(echo "$PKGNAME" | sed -E 's/[_]/ /g; s/[[:space:]]*-linux$//i')
    SUPPORTEDARCHES=$(extract_var SUPPORTEDARCHES $SH_FILE)
    VERSION=$(extract_var VERSION $SH_FILE)
    DESCRIPTION=$(extract_var DESCRIPTION $SH_FILE)
    URL=$(extract_var URL $SH_FILE)

    DOWNLOAD_PAGE=$(extract_pkgurl $SH_FILE)
    DOWNLOAD_MASK=$(extract_download_mask $SH_FILE)

    if [ -z "$PKGNAME" ]; then
        echo "$SH_FILE пропущен: PKGNAME не найден" >> "$LOG_FILE"
        continue
    fi

    if echo "$DESCRIPTION" | grep -qE "^\s*#"; then
        echo "$SH_FILE пропущен: комментарии в description" >> "$LOG_FILE"
        continue
    fi

    YAML_FILE=yaml.d/${PKGNAME}.yaml

    REPLACED_DOWNLOAD_PAGE=$(replace_vars "$DOWNLOAD_PAGE")
    REPLACED_DOWNLOAD_MASK=$(replace_vars "$DOWNLOAD_MASK")

    echo "apps:" > "$YAML_FILE"
    echo "  - name: $PKGNAME" >> "$YAML_FILE"
    echo "    group: $PKGNAME group" >> "$YAML_FILE"
    echo "    license: $PKGNAME license" >> "$YAML_FILE"
    echo "    url: $URL" >> "$YAML_FILE"
    echo "    summary: $PKGNAME summary" >> "$YAML_FILE"
    echo "    description: $DESCRIPTION" >> "$YAML_FILE"
    echo "    arches: $SUPPORTEDARCHES" >> "$YAML_FILE"
    echo "    download_page: $REPLACED_DOWNLOAD_PAGE" >> "$YAML_FILE"

    if [ "$DOWNLOAD_MASK" != "$DOWNLOAD_PAGE" ] && [ "$DOWNLOAD_MASK" != "$(basename "$DOWNLOAD_PAGE")" ]; then
        echo "    download_mask: $REPLACED_DOWNLOAD_MASK" >> "$YAML_FILE"
    fi

    echo "YAML файл сгенерирован: $YAML_FILE"
done
