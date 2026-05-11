# epm play saby — анализ postinstall скриптов и репак

## Зачем нужен repack

Оригинальные RPM/DEB пакеты Saby (`saby.rpm`, `sabycenter.rpm`, `nmh-transport.rpm`)
содержат postinstall/preuninstall скрипты с рядом проблем безопасности и
архитектурных ошибок. При установке через epm мы отказываемся от скриптов в
пользу перепаковки (`epm install` без флага `--scripts`).

## Проблемы в оригинальных скриптах

### 1. chmod 777 на каталоги и файлы логов
Скрипты создают `/usr/share/Tensor/Saby/logs/installer_logs` с правами 777.
Файлы логов создаются с правами 666. Любой пользователь системы может
читать, изменять и удалять логи. Возможна symlink-атака.

### 2. eval в функции command_call
Все команды во всех скриптах выполняются через `eval` — собираются из строк
и запускаются. Паттерн опасен при некорректных аргументах.

### 3. killall -9 без ограничения по пользователю
При установке/обновлении убиваются процессы `saby`/`sabycenter`/`ChromeNmhTransport`
у ВСЕХ пользователей системы. В многопользовательской среде это приводит к потере
работы у других пользователей.

### 4. Запуск недокументированного бинарника components-registrator от root
postinstall запускает `components-registrator installActions/installCenter/installNmh`
с привилегиями root. Действия бинарника не документированы и не верифицируемы.

### 5. Запись shell-скрипта в /usr/bin/
preinstall создаёт `/usr/bin/saby-install.common.sh`, который затем `source`'ится
из всех остальных скриптов. Между preinstall и postinstall файл может быть подменён
(TOCTOU — code injection).

### 6. Модификация системных конфигов abrt (CentOS/RED OS)
Скрипт sabycenter меняет `/etc/abrt/abrt.conf`:
- `OpenGPGCheck = no` — отключение проверки GPG-подписей
- `ProcessUnpackaged = yes` — обработка неупакованных файлов

Это снижает безопасность системы и не относится к функциональности Saby.

### 7. Использование /usr/share/ для runtime данных
`/usr/share/Tensor/Saby/` используется для логов, маркерных файлов, ini-настроек.
По FHS `/usr/share/` предназначен для read-only данных. Runtime данные должны быть
в `/var/lib/` или `~/.local/share/`.

### 8. Хак с temp_saby
RPM содержит все файлы в `/opt/Tensor/Saby/temp_saby/`. postinstall скрипт
перемещает их в `/opt/Tensor/Saby/` через `cp -r ... && rm -rf temp_saby`.
Это обходной путь для обновления (нельзя перезаписать работающие бинарники).
При этом postinstall создаёт пустые файлы-заглушки в `temp_saby/` по образу
реальных файлов — чтобы rpm не ругался при удалении на отсутствующие файлы.
Весь этот механизм — следствие того, что авторы пакета работают мимо пакетного
менеджера, используя RPM лишь как транспорт.

### 9. Архитектурная ошибка: /usr/share/ для mutable данных
RPM не содержит ни одного файла в `/usr/share/`. Каталог `/usr/share/Tensor/Saby/`
создаётся postinstall скриптом и используется для:
- логов установки (`logs/installer_logs/`)
- маркерных файлов (`afterInstall.marker`)
- ini-настроек

По FHS `/usr/share/` предназначен для архитектурно-независимых read-only данных.
Mutable runtime данные (логи, настройки, маркеры) должны быть в `/var/lib/`,
`/var/log/` или `~/.local/share/`.

## Структура пакетов

- **saby.rpm** (~280 MB) — основное приложение. Все файлы в `/opt/Tensor/Saby/temp_saby/<VERSION>/`. Бинарь-лаунчер: `temp_saby/saby` (~200 KB).
- **sabycenter.rpm** (~40 MB) — серверная часть (systemd service `SabyCenter.service`). Путь: `/opt/Tensor/Saby Center/temp_sabycenter/<VERSION>/` *(пробел в пути!)*.
- **nmh-transport.rpm** (~13 MB) — расширение для браузера (Native Messaging Host). Путь: `/opt/nmh-transport/temp_nmh/<VERSION>/`.
- **sbis-libstdc++12** (~7 MB) — libstdc++ 12 для старых систем. Кладёт в `/opt/gcc-*/lib64/`.

## libstdc++12: когда ставится

`saby.rpm` требует символ `GLIBCXX_3.4.30` (= GCC 12). Условие
`is_stdcpp_enough 12` проверяет версию системного `libstdc++`/`libstdc++6`:

- ALT Sisyphus (libstdc++6 = 15.2.x), современная Ubuntu/Fedora — условие
  проходит, sbis-libstdc++12 НЕ ставится.
- CentOS 7, RED OS 7.x, старые Ubuntu (libstdc++ < 12) — условие срабатывает,
  sbis-libstdc++12 ставится корректно.

Если ранее запускался `epm install --scripts saby.rpm`, maintainer-скрипты
могли тянуть libstdc++12 транзитивно даже при достаточной версии. После перехода
на установку без `--scripts` пакет ставится через repack, скрипты отбрасываются.

## Что заменено в repack.d (вместо postinstall)

- **`temp_*` → `PRODUCTDIR`**: оригинальные RPM кладут все файлы в
  `temp_saby/`, `temp_sabycenter/`, `temp_nmh/`. postinstall делает
  `cp -r temp_*/. PRODUCTDIR/` и удаляет `temp_*/`. В repack используется
  `move_dir` (см. `repack.d/{saby,sabycenter,nmh-transport}.sh`).
- **Desktop файлы**: `/usr/share/applications/Saby.desktop` создаётся в
  `repack.d/saby.sh`.
- **Autostart**: `/etc/xdg/autostart/ru.tensor.Saby.desktop` создаётся в
  `repack.d/saby.sh`. Это **системно для всех пользователей** — Saby стартует
  у каждого при входе в графическую сессию (как и в оригинальных скриптах).
- **Симлинки `/usr/bin/saby`, `/usr/bin/sabycenter`** через `add_bin_link_command`.

## Что переехало в play.d/saby.sh (после установки пакетов)

- **`sbis-plugin-connector-path`** — путь к `libsbis-plugin-connector.so`
  (для интеграции с браузерным плагином sbis3plugin).
- **`components-registrator installNmh`** — регистрация Native Messaging Host
  для браузеров (нужно для работы плагина в Chrome/Yandex/Edge/Firefox).
  Это всё ещё запуск недокументированного бинарника от root (см. п. 4 выше),
  но без него плагин не функционален.
- **Подсказка про SabyCenter service** — печатается в конце. Регистрация
  systemd-сервиса (`sbis-daemon-setup.sh`) сложнее и потенциально ломает
  поведение системы — оставлено пользователю.

## Что отброшено сознательно

- `chmod 777` на `/usr/share/Tensor/*/logs/installer_logs/` (см. п. 1).
- `killall -9` глобально (см. п. 3).
- Запись `/usr/bin/saby-install.common.sh` (см. п. 5).
- `eval`-обёртка `command_call` (см. п. 2).
- Изменения `/etc/abrt/abrt.conf` (см. п. 6).
- Stub-файлы в `temp_*` (см. п. 8) — нужны были авторам пакета,
  чтобы rpm не ругался при удалении в их флоу. При репаке не нужны.
- per-user install скрипты в `/etc/profile.d/` (создают ярлык на рабочем
  столе пользователя) — лишний шум, ярлык в меню есть.
- Создание `/usr/share/Tensor/Saby/` как mutable storage (см. п. 7, 9).
  Сохранена только запись `sbis-plugin-connector-path` — этот путь нужен
  плагину sbis3plugin для коммуникации (формальный нарушитель FHS, но
  функционально критичный).

## Что **не** проверено и может потребовать ручной настройки

- Корректность работы плагина в браузере зависит от того, как
  `components-registrator installNmh` регистрирует Native Messaging Host
  (создаёт JSON-манифесты в `/etc/opt/<browser>/native-messaging-hosts/`).
  Проверять отдельно.
- SabyCenter как systemd-сервис — после установки не запускается автоматически.
  Для запуска через системный `SabyCenter.service` нужно вручную выполнить
  `sbis-daemon-setup.sh ... install` или запускать SabyCenter из меню
  (как обычное приложение).
