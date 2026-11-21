#!/bin/sh

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
EPM="$ROOT/bin/epm"

assert_contains()
{
    value="$1"
    expected="$2"
    printf '%s\n' "$value" 2>/dev/null | grep -Fqx "$expected" || {
        echo "Expected: $expected" >&2
        echo "Actual: $value" >&2
        exit 1
    }
}

list_play()
{
    env -u LC_ALL -u LC_MESSAGES LANG="$1" "$EPM" play --quiet --list-all
}

assert_contains "$(list_play ru_RU.UTF-8)" 'telegram - Клиент Telegram с официального сайта'
assert_contains "$(list_play de_DE.UTF-8)" 'telegram - Telegram client from the official site'
assert_contains "$(list_play pt_BR.UTF-8)" 'telegram - Telegram client from the official site'
assert_contains "$(list_play sr_RS.UTF-8@latin)" 'telegram - Telegram client from the official site'
assert_contains "$(list_play C)" 'telegram - Telegram client from the official site'
assert_contains "$(list_play POSIX)" 'telegram - Telegram client from the official site'
assert_contains "$(list_play invalid)" 'telegram - Telegram client from the official site'
assert_contains "$(env LC_ALL=C LC_MESSAGES=ru_RU.UTF-8 LANG=ru_RU.UTF-8 "$EPM" play --quiet --list-all)" 'telegram - Telegram client from the official site'
assert_contains "$(env -u LC_ALL LC_MESSAGES=C LANG=ru_RU.UTF-8 "$EPM" play --quiet --list-all)" 'telegram - Telegram client from the official site'
assert_contains "$(env -u LC_ALL -u LC_MESSAGES -u LANG "$EPM" play --quiet --list-all)" 'telegram - Telegram client from the official site'

assert_contains "$(env -u LC_ALL -u LC_MESSAGES LANG=ru_RU.UTF-8 "$EPM" play --search 'Клиент Telegram с официального сайта')" '  telegram                  - Клиент Telegram с официального сайта'
assert_contains "$(env -u LC_ALL -u LC_MESSAGES LANG=ru_RU.UTF-8 "$EPM" play --search 'Telegram client from the official site')" '  telegram                  - Клиент Telegram с официального сайта'
assert_contains "$(env -u LC_ALL -u LC_MESSAGES LANG=ru_RU.UTF-8 "$EPM" play --search 'с официального сайта$')" '  telegram                  - Клиент Telegram с официального сайта'
assert_contains "$(env -u LC_ALL -u LC_MESSAGES LANG=ru_RU.UTF-8 "$EPM" play --search 'from the official site$')" '  telegram                  - Клиент Telegram с официального сайта'
assert_contains "$(env -u LC_ALL -u LC_MESSAGES LANG=ru_RU.UTF-8 "$EPM" prescription --quiet --list-all)" 'snap - Добавить поддержку Snap в систему'

short_c="$(env -u LC_ALL -u LC_MESSAGES LANG=C "$EPM" play --short --list-all)"
short_ru="$(env -u LC_ALL -u LC_MESSAGES LANG=ru_RU.UTF-8 "$EPM" play --short --list-all)"
[ "$short_c" = "$short_ru" ]

# Exercise additional languages using metadata fixtures, not production translations.
. "$ROOT/bin/epm-play-common"
unset LC_ALL LC_MESSAGES
metadata()
{
    printf '%s\n' \
        "fixture.sh:DESCRIPTION='Base'" \
        "fixture.sh:DESCRIPTION_ru='Русский'" \
        "fixture.sh:DESCRIPTION_de='Deutsch'" \
        "fixture.sh:DESCRIPTION_pt='Português'" \
        "fixture.sh:DESCRIPTION_sr='Srpski'" \
        "fixture.sh:DESCRIPTION_fr=''"
}
check_language()
{
    result="$(metadata | LANG="$1" __select_app_descriptions | cut -d "$(printf '\036')" -f2)"
    [ "$result" = "$2" ] || { echo "Locale $1: expected $2, got $result" >&2; exit 1; }
}
check_language de_DE.UTF-8 Deutsch
check_language pt_BR.UTF-8 Português
check_language sr_RS.UTF-8@latin Srpski
check_language ru_RU.KOI8-R Русский
check_language fr_FR.UTF-8 Base
check_language ru_ Base
check_language 'ru.invalid locale' Base
check_language C.UTF-8 Base
check_language '' Base
assert_contains "$(printf '%s\n' \
    "comment.sh:DESCRIPTION='Text # inside' # comment with 'quotes'" \
    "hidden.sh:DESCRIPTION='' # hidden" | LANG=C __select_app_descriptions | cut -d "$(printf '\036')" -f2)" 'Text # inside'
assert_contains "$(printf '%s\n' \
    'quoted.sh:DESCRIPTION="A \"quoted\" description" # comment' \
    'slash.sh:DESCRIPTION="Path C:\\tools and \q"' \
    "single.sh:DESCRIPTION='Literal \\ path'" \
    'bad.sh:DESCRIPTION="Unclosed \"quote\"' \
    'translated.sh:DESCRIPTION="Base"' \
    'translated.sh:DESCRIPTION_ru="Перевод \"с кавычками\""' \
    | LANG=ru_RU.UTF-8 __select_app_descriptions | cut -d "$(printf '\036')" -f2)" 'A "quoted" description'

quoted="$(printf '%s\n' \
    'slash.sh:DESCRIPTION="Path C:\\tools and \q"' \
    "single.sh:DESCRIPTION='Literal \\ path'" \
    'translated.sh:DESCRIPTION="Base"' \
    'translated.sh:DESCRIPTION_ru="Перевод \"с кавычками\""' \
    | LANG=ru_RU.UTF-8 __select_app_descriptions | cut -d "$(printf '\036')" -f2)"
assert_contains "$quoted" 'Path C:\tools and \q'
assert_contains "$quoted" 'Literal \ path'
assert_contains "$quoted" 'Перевод "с кавычками"'
[ -z "$(printf '%s\n' 'bad.sh:DESCRIPTION="Unclosed \"quote\"' | LANG=C __select_app_descriptions)" ]

# Stub only the catalogue, retaining the real search implementation.
(
    SYSTEMARCH=x86_64
    __get_fast_int_list_app() { :; }
    [ -z "$(__epm_play_search nonexistent)" ]
    [ -z "$(__epm_play_search '.*')" ]
    __get_fast_int_list_app() { printf 'demo\036Description\036Base\n'; }
    [ -z "$(__epm_play_search nonexistent)" ]
    assert_contains "$(__epm_play_search 'Description$')" '  demo                      - Description'
)
echo 'Localized description tests passed'
