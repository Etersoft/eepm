# epm play saby — анализ postinstall скриптов

## Зачем нужен repack

Оригинальные RPM/DEB пакеты Saby (saby.rpm, sabycenter.rpm, nmh-transport.rpm)
содержат postinstall/preuninstall скрипты с рядом проблем безопасности.
При установке через epm мы отказываемся от скриптов в пользу перепаковки.

## Проблемы в скриптах

### 1. chmod 777 на каталоги и файлы логов
Скрипты создают `/usr/share/Tensor/Saby/logs/installer_logs` с правами 777.
Файлы логов создаются с правами 666. Любой пользователь системы может
читать, изменять и удалять логи. Возможна symlink-атака.

### 2. eval в функции command_call
Все команды во всех скриптах выполняются через `eval` — собираются из строк
и запускаются. Паттерн опасен при некорректных аргументах.

### 3. killall -9 без ограничения по пользователю
При установке/обновлении убиваются процессы saby/sabycenter/ChromeNmhTransport
у ВСЕХ пользователей системы. В многопользовательской среде это приводит к потере
работы у других пользователей.

### 4. Запуск недокументированного бинарника components-registrator от root
postinstall запускает `components-registrator installActions` с привилегиями root.
Действия бинарника не документированы и не верифицируемы.

### 5. Запись shell-скрипта в /usr/bin/
preinstall создаёт `/usr/bin/saby-install.common.sh`, который затем source'ится
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

- **saby.rpm** (~280 MB) — основное приложение. Все файлы в `/opt/Tensor/Saby/temp_saby/VERSION/`.
- **sabycenter.rpm** (~105 MB) — серверная часть (systemd service SabyCenter).
- **nmh-transport.rpm** (~15 MB) — расширение для браузера (Native Messaging Host).
- **sbis-libstdc++12** (~7 MB) — libstdc++ 12 для старых систем.

## Что можно перенести в repack.d

- Создание desktop-файлов и autostart → repack.d
- Установка systemd service → repack.d
- Иконки → repack.d
- Symlink /usr/bin/saby → repack.d
- Каталоги логов с нормальными правами → repack.d

## Что нельзя заменить без тестирования

- `components-registrator installActions` — без него приложение может не запуститься
- Создание per-user маркерных файлов — влияет на автозапуск
