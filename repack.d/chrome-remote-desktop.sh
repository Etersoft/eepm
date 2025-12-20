#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=chrome-remote-desktop

# install all requires packages before packing ($ rpmreqs chrome-remote-desktop  | xargs echo)
#PREINSTALL_PACKAGES="coreutils glib2 libcairo libdbus libdrm libexpat libgbm libgio libgtk+3 libnspr libnss libpango libX11 libxcb libXdamage libXext libXfixes libXrandr libXtst libutempter \
#     python3-base python3-module-psutil python3"

. $(dirname $0)/common-chromium-browser.sh

cleanup

# eepm-rpm-build doesn't support BRs
#subst '1iBuildRequires:rpm-build-python3' $SPEC
#set_autoreq 'yes'

# add_unirequires "python3(pyxdg)"
add_requires python3-module-pyxdg

rm -R "$BUILDROOT/etc/pam.d"

mkdir -p $BUILDROOT/etc/pam.d
cat <<'EOF' > "$BUILDROOT/etc/pam.d/chrome-remote-desktop"
auth        required    pam_unix.so
account     required    pam_unix.so
password    required    pam_unix.so
session     required    pam_unix.so
EOF
pack_file /etc/pam.d/chrome-remote-desktop


mkdir -p $BUILDROOT/usr/bin
cat <<'EOF' > "$BUILDROOT/usr/bin/crd"
#!/bin/bash

# Функции для цветного вывода текста
print_red() {
  printf "$(tput setaf 1)$1$(tput sgr0)"
}
print_green() {
  printf "$(tput setaf 2)$1$(tput sgr0)"
}
print_blue() {
  printf "$(tput setaf 4)$1$(tput sgr0)"
}

# Функция для показа статуса CRD
status() {
  local crd_status
  crd_status=$(/opt/google/chrome-remote-desktop/chrome-remote-desktop --get-status)
  print_blue "CRD status: "; print_green "${crd_status}"; echo
}

# Перезагрузка сервиса
reload() {
  /opt/google/chrome-remote-desktop/chrome-remote-desktop --reload
}

# Остановка сервиса
stop() {
  /opt/google/chrome-remote-desktop/chrome-remote-desktop --stop
  rm -rf "${HOME}/.config/chrome-remote-desktop/pulseaudio"*
}

# Запуск сервиса
start() {
  if [ ! -f "${HOME}/.chrome-remote-desktop-session" ]; then
    print_red "Настройка не завершена. Выполните: crd --setup"; echo
    exit 1
  fi

  # Проверяем наличие хотя бы одного файла host*.json
  if ! ls "${HOME}/.config/chrome-remote-desktop"/host*.json >/dev/null 2>&1; then
    print_red "Не активирован CRD в браузере. Активируйте его перед запуском сервера."; echo
    exit 1
  fi

  rm -rf "${HOME}/.config/chrome-remote-desktop/pulseaudio"*
  local crd_size
  crd_size=$(cat "${HOME}/.config/chrome-remote-desktop/Size")
  if [ -z "${crd_size}" ]; then
    /opt/google/chrome-remote-desktop/chrome-remote-desktop --start
  else
    /opt/google/chrome-remote-desktop/chrome-remote-desktop --size="${crd_size}" --start
  fi
}

# Перезапуск сервиса
restart() {
  stop
  sleep 1
  start
}

# Интерактивная настройка CRD
setup() {
  print_blue "Проверка наличия рабочей директории и файла сессии:"; echo
  print_blue "Директории: "; print_green "${HOME}/.config/chrome-remote-desktop"; echo "и"; print_green "${HOME}/.chrome-remote-desktop-session"; echo

  [ -d "${HOME}/.config/chrome-remote-desktop" ] || mkdir -p "${HOME}/.config/chrome-remote-desktop"
  touch "${HOME}/.chrome-remote-desktop-session"
  touch "${HOME}/.config/chrome-remote-desktop/Size"

  # Проверка наличия редактора, по умолчанию nano
  EDITOR="${VISUAL:-${EDITOR:-nano}}"
  if ! command -v "${EDITOR}" >/dev/null 2>&1; then
    print_red "Редактор ${EDITOR} не найден. Задайте переменную EDITOR."; echo
    exit 1
  fi

  local crd_session="${HOME}/.chrome-remote-desktop-session"
  if [ -z "$(cat "${crd_session}")" ]; then
    echo "# Раскомментируйте одну из следующих строк для работы CRD" >> "${crd_session}"
    echo "# Удалите # и сохраните файл." >> "${crd_session}"
    echo "#" >> "${crd_session}"
    echo "export \$(dbus-launch)" >> "${crd_session}"
    grep -R "^Exec=" "/usr/share/xsessions/" | sed "s|/usr/.*=|#exec |" >> "${crd_session}"
  fi

  print_blue "Открываем редактор для настройки файла сессии."; echo
  read -rsp "Нажмите любую клавишу для продолжения..." -n1 key; echo
  "${EDITOR}" "${crd_session}"
  sleep 0.5

  print_blue "############################################################"; echo
  local crd_size_file="${HOME}/.config/chrome-remote-desktop/Size"
  print_blue "Если хотите задать размер по умолчанию для всех клиентов, введите значение в формате [ширина]x[высота] (например, 1360x768) в файле:"; echo
  print_green "${crd_size_file}"; echo
  print_blue "Если размер задавать не нужно – оставьте файл пустым."; echo
  print_blue "Открываем редактор для настройки файла размера."; echo
  read -rsp "Нажмите любую клавишу для продолжения..." -n1 key; echo
  "${EDITOR}" "${crd_size_file}"
  sleep 0.5

  print_blue "############################################################"; echo
  print_blue "Настройка завершена."; echo
  print_blue "Разрешите Chrome/Chromium работать в качестве сервера, открыв:"; echo
  print_green "https://remotedesktop.google.com/headless/"; echo
  print_blue "и следуя инструкциям."; echo
  print_blue "Для автозапуска сервиса выполните:"; echo
  print_green "systemctl enable chrome-remote-desktop@${USER}"; echo

  if [ "$(whoami)" = "root" ]; then
    print_red "Запустите этот скрипт от имени обычного пользователя!"; echo
    exit 1
  fi
}

# Обработка параметров командной строки
case "$1" in
  --status)
    status
    ;;
  --restart)
    restart
    ;;
  --reload)
    reload
    ;;
  --stop)
    stop
    ;;
  --start)
    start
    ;;
  --setup)
    setup
    ;;
  *)
    echo "Использование: $0 {--setup|--start|--stop|--restart|--reload|--status}"
    exit 1
    ;;
esac
EOF
chmod a+x $BUILDROOT/usr/bin/crd
sed -i '/^Environment=/ s/$/ XAUTHORITY=\/home\/%i\/.Xauthority/' $BUILDROOT/lib/systemd/system/chrome-remote-desktop@.service

pack_file /usr/bin/crd

