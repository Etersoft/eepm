# Help System and Shell Completion

Документация для разработчиков по системе справки и автодополнения в epm.

## Маркеры справки

Команды и опции документируются специальными комментариями, которые парсятся функцией `get_help()`.

### Типы маркеров

| Маркер | Назначение | Пример |
|--------|------------|--------|
| `HELPCMD` | Описание команды/подкоманды | `install\|i) # HELPCMD: install package(s)` |
| `HELPOPT` | Описание опции | `--verbose) # HELPOPT: verbose mode` |
| `HELPSHORT` | Описание короткого алиаса | Используется в главном скрипте epm |

### Формат комментариев

```bash
# В case-блоке:
case "$option" in
    -h|--help)           # HELPOPT: show this help
        ...
        ;;
    --installed)         # HELPOPT: search in installed packages
        ...
        ;;
    add|remove)          # HELPCMD: add or remove something
        ...
        ;;
esac
```

### Использование get_help()

```bash
epm_mycommand_help()
{
    # Заголовок (message выводит без перевода строки в конце)
    message 'epm mycommand - описание команды
Usage: epm mycommand [options] <args>
'
    # Опции из текущего файла
    get_help HELPOPT $SHAREDIR/epm-mycommand

    # Подкоманды (если есть)
    get_help HELPCMD $SHAREDIR/epm-mycommand
}
```

### Паттерн парсинга опций

Рекомендуемый способ (как в epm-list, epm-search):

```bash
epm_mycommand()
{
    local option="$1"

    case "$option" in
        -h|--help)           # HELPOPT: show this help
            epm_mycommand_help
            return
            ;;
        --installed)         # HELPOPT: search in installed packages
            shift
            do_installed_search "$@"
            return
            ;;
        --available)         # HELPOPT: search in available packages (default)
            shift
            ;;
    esac

    # Поведение по умолчанию
    [ -n "$1" ] || fatal "Missing argument"
    do_default_action "$@"
}
```

## Маркеры автодополнения (COMPLETE:)

Для shell completion команды могут указывать тип аргумента через маркер `COMPLETE:type`.

### Формат

```bash
# В bin/epm:
install|i)  # HELPCMD: install package(s) COMPLETE:package
remove|rm)  # HELPCMD: remove package(s) COMPLETE:package_installed
play)       # HELPCMD: install application COMPLETE:playapp
repo)       # HELPCMD: repository management COMPLETE:repo
repack)     # HELPCMD: repack package COMPLETE:file
```

### Доступные типы

| Тип | Описание | Источник данных |
|-----|----------|-----------------|
| `package` | Доступные пакеты | `epm list --available` |
| `package_installed` | Установленные пакеты | `epm qp` |
| `playapp` | Приложения epm play | `epm play --list-all` |
| `prescription` | Рецепты prescription | `epm prescription --list-all` |
| `repo` | Имена репозиториев | `epm repo list` |
| `file` | Пути к файлам | Стандартное дополнение файлов |

### Получение данных для completion

```bash
# Список команд с описаниями и типами аргументов (TSV)
epm tool epm-completion commands

# Список опций
epm tool epm-completion options

# Список алиасов
epm tool epm-completion aliases

# Опции подкоманды
epm tool epm-completion repo
epm tool epm-completion play
```

Формат вывода TSV: `команда<TAB>описание[<TAB>тип_аргумента]`

## Shell Completion Scripts

Скрипты автодополнения находятся в `completions/`:

```
completions/
├── bash/
│   ├── eepm          # bash completion
│   └── serv
├── zsh/
│   ├── _eepm         # zsh completion (главная функция _epm)
│   └── _serv
└── fish/
    ├── eepm.fish     # fish completion
    └── *.fish        # симлинки для алиасов
```

### Соглашения по именованию функций

- **bash**: `__eepm_*` (например, `__eepm_list_installed_packages`)
- **zsh**: `__eepm_*` для внутренних, `_epm` для главной (требование zsh)
- **fish**: `__eepm_*` (например, `__eepm_list_commands`)

### Тестирование completion

```bash
# Автоматические тесты
./tests/test_completions.sh

# Ручное тестирование - см. completions/README.md
```

## Добавление новой команды

1. Создать `bin/epm-mycommand`
2. Добавить case в `bin/epm` с маркером `HELPCMD` и опционально `COMPLETE:`
3. Реализовать `epm_mycommand_help()` с использованием `get_help`
4. Если нужны свои опции - парсить их внутри команды (паттерн epm-list)
