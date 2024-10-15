#!/bin/sh

DIR=play.d

extract_var() {
    # Получаем значение переменной и убираем кавычки
    grep -E "^$1=" "$2" | sed -E "s/^$1=(.*)/\1/" | tr -d '"' | tr -d "'"
}

extract_pkgurl() {
	# Вырезаем функции что бы получить чистый url, а так же игнорируем строки с коментариями
    if grep -q "^[^#]*get_github_url" "$1"; then
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/.*get_github_url (https[^ ]+).*/\1/' | tr -d '"'
    elif grep -q "^[^#]*eget --list --latest" "$1"; then
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/.*eget --list --latest (https[^ ]+).*/\1/' | tr -d '"'
    else
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/^PKGURL=(.*)/\1/' | tr -d '"'
    fi
}

extract_download_mask() {
	# Вырезаем функции что бы получить чистый url, а так же игнорируем строки с коментариями
    if grep -q "^[^#]*get_github_url" $1; then
        grep -E "^[^#]*^PKGURL=" $1 | sed -E 's/.*get_github_url [^ ]+ ([^ ]+).*/\1/' | sed 's/[)"]*$//' | tr -d '"'
    elif grep -q "^[^#]*eget --list --latest" $1; then
        grep -E "^[^#]*^PKGURL=" $1 | sed -E 's/.*eget --list --latest [^ ]+ ([^ ]+).*/\1/' | sed 's/[)"]*$//' | tr -d '"'
    else
        grep -E "^[^#]*^PKGURL=" "$1" | sed -E 's/^PKGURL=(.*)/\1/' | tr -d '"'
    fi
}

for SH_FILE in $DIR/*.sh; do
    if echo $SH_FILE | grep -q "common"; then
        continue
    fi

    # Извлечение переменных из .sh файла
    PKGNAME=$(extract_var PKGNAME $SH_FILE)
    SUPPORTEDARCHES=$(extract_var SUPPORTEDARCHES $SH_FILE)
    VERSION=$(extract_var VERSION $SH_FILE)
    DESCRIPTION=$(extract_var DESCRIPTION $SH_FILE)
    DESCRIPTION_CLEAN=$(echo "$DESCRIPTION" | grep -vE "^\s*#\s*echo|^\s*#")
    URL=$(extract_var URL $SH_FILE)

    DOWNLOAD_PAGE=$(extract_pkgurl $SH_FILE)
    DOWNLOAD_MASK=$(extract_download_mask $SH_FILE)

    if [ -z "$PKGNAME" ]; then
        echo "PKGNAME для $SH_FILE не найден..."
        continue
    fi

    YAML_FILE=yaml.d/${PKGNAME}.yaml

    # Автогенерация YAML
    echo "apps:" > "$YAML_FILE"
    echo "  - name: $PKGNAME" >> "$YAML_FILE"
    echo "    group: $PKGNAME group" >> "$YAML_FILE"  # ?
    echo "    license: $PKGNAME license:" >> "$YAML_FILE"       # ?
    echo "    url: $URL" >> "$YAML_FILE"
    echo "    summary: $PKGNAME summary" >> "$YAML_FILE"    # ?
    echo "    description: $DESCRIPTION_CLEAN" >> "$YAML_FILE"
    echo "    arches: $SUPPORTEDARCHES" >> "$YAML_FILE"
    echo "    download_page: $DOWNLOAD_PAGE" >> "$YAML_FILE"

	if [ "$DOWNLOAD_MASK" != "$DOWNLOAD_PAGE" ] && [ "$DOWNLOAD_MASK" != "$(basename "$DOWNLOAD_PAGE")" ]; then
	    echo "    download_mask: $DOWNLOAD_MASK" >> "$YAML_FILE"
	fi

    echo "YAML файл сгенерирован: $YAML_FILE"
done

