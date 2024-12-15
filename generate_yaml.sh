#!/bin/sh

DIR=play.d

extract_var() {
    # Получаем значение переменной и убираем кавычки
    grep -E "^$1=" "$2" | sed -E "s/^$1=(.*)/\1/" | tr -d '"' | tr -d "'"
}

extract_pkgurl() {
    # Вырезаем функции что бы получить чистый url, а так же игнорируем строки с коментариями
    if grep -q "^[^#]*get_github_url" "$1"; then
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/.*get_github_url[[:space:]]+([^[:space:]]+).*/\1/' | tr -d '"'
    elif grep -q "^[^#]*eget --list --latest" "$1"; then
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/.*eget --list --latest[[:space:]]+([^[:space:]]+).*/\1/' | tr -d '"'
    else
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/^PKGURL=(.*)/\1/' | tr -d '"'
    fi
}

extract_download_mask() {
    # Вырезаем функции что бы получить чистый url, а так же игнорируем строки с коментариями
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

for SH_FILE in $DIR/*.sh; do
    if echo $SH_FILE | grep -q "common"; then
        continue
    fi

    # Извлечение переменных из .sh файлов
    PKGNAME=$(extract_var PKGNAME $SH_FILE)
    SUPPORTEDARCHES=$(extract_var SUPPORTEDARCHES $SH_FILE)
    VERSION=$(extract_var VERSION $SH_FILE)
    DESCRIPTION=$(extract_var DESCRIPTION $SH_FILE)
    URL=$(extract_var URL $SH_FILE)

    DOWNLOAD_PAGE=$(extract_pkgurl $SH_FILE)
    DOWNLOAD_MASK=$(extract_download_mask $SH_FILE)

    if [ -z "$PKGNAME" ]; then
        echo "PKGNAME для $SH_FILE не найден..."
        continue
    fi

    if echo "$DESCRIPTION" | grep -qE "^\s*#"; then
        echo "Скрипт $SH_FILE содержит комментарии в description и будет пропущен."
        continue
    fi

    YAML_FILE=yaml.d/${PKGNAME}.yaml

    REPLACED_DOWNLOAD_PAGE=$(replace_vars "$DOWNLOAD_PAGE")
    REPLACED_DOWNLOAD_MASK=$(replace_vars "$DOWNLOAD_MASK")

    # Auto-generate YAML
    echo "apps:" > "$YAML_FILE"
    echo "  - name: $PKGNAME" >> "$YAML_FILE"
    echo "    group: $PKGNAME group" >> "$YAML_FILE"  # ?
    echo "    license: $PKGNAME license" >> "$YAML_FILE"       # ?
    echo "    url: $URL" >> "$YAML_FILE"
    echo "    summary: $PKGNAME summary" >> "$YAML_FILE"    # ?
    echo "    description: $DESCRIPTION" >> "$YAML_FILE"
    echo "    arches: $SUPPORTEDARCHES" >> "$YAML_FILE"
    echo "    download_page: $REPLACED_DOWNLOAD_PAGE" >> "$YAML_FILE"

    if [ "$DOWNLOAD_MASK" != "$DOWNLOAD_PAGE" ] && [ "$DOWNLOAD_MASK" != "$(basename "$DOWNLOAD_PAGE")" ]; then
        echo "    download_mask: $REPLACED_DOWNLOAD_MASK" >> "$YAML_FILE"
    fi

    echo "YAML файл сгенерирован: $YAML_FILE"
done
