#!/bin/sh
# Generate a Telegram press release from the latest eepm changelog entry
# Usage: ./make-press-release.sh [specfile]

SPECNAME="${1:-eepm.spec}"
SCRIPTDIR="$(dirname "$0")"
SPECFILE="$SCRIPTDIR/$SPECNAME"

if [ ! -f "$SPECFILE" ] ; then
    echo "Error: spec file '$SPECFILE' not found" >&2
    exit 1
fi

# Extract the latest changelog block (from %changelog to the next empty line before the next * entry)
changelog_block=$(sed -n '/^%changelog$/,/^$/{/^%changelog$/d;p}' "$SPECFILE" | sed '/^$/q')

if [ -z "$changelog_block" ] ; then
    echo "Error: no changelog entries found in $SPECFILE" >&2
    exit 1
fi

# Extract version from the header line
version=$(echo "$changelog_block" | head -1 | sed 's/.*> //' | sed 's/-alt.*//')

echo "Generating press release for epm $version ..." >&2

prompt_text=$(cat <<'PROMPT_END'
You are an expert at writing concise technical press releases in Russian for the Telegram messenger.

You will receive a changelog block from an RPM spec file for the "epm" package manager. Transform it into a readable Telegram press release.

FORMAT RULES (Telegram MarkdownV2-compatible plain text):
- Title line: use **bold** for the title, e.g.: **Выпущена стабильная версия epm X.Y.Z**
- Section headers: use **bold**, e.g.: **Улучшения в epm play:**
- Commands and code: use `backtick mono`, e.g.: `epm upgrade`
- Bullet points: use " • " (space-bullet-space) for list items
- NO HTML tags. NO [links](url). Just plain text with *bold* and `mono`.
- Leave an empty line between sections.
- Do not use any other Markdown formatting (no _, no ~, no ||).
- Escape literal * and ` in text with backslash if they appear literally (not as formatting).

CONTENT RULES:
- Start with the title: *Выпущена стабильная версия epm VERSION*
- Then the update instructions block (always the same):

Обновиться можно командой `epm upgrade` (для ALT Sisyphus (не сразу) или Ximper Linux), а для стабильных бранчей ALT:

`epm upgrade "https://download.etersoft.ru/pub/Korinf/x86_64/ALTLinux/p11/eepm-*.noarch.rpm"`

или `epm ei` (для остальных систем)

- Group changelog entries into logical sections. Typical sections:
  - *Улучшения в epm repack:* — repack-related changes
  - *Улучшения в epm play:* — play-related changes (new apps, fixes to play scripts)
  - *Улучшения в eget:* — eget-related changes
  - *Исправления в epm:* — general epm fixes, install/remove/repo commands
  - *Прочее:* — everything else (erc, AppImage, misc)
  - *Новые приложения в epm play:* — if there are several new apps added
  - Only include sections that have entries. Merge small groups into related sections.
- Translate technical English changelog entries into clear, concise Russian.
- Combine closely related entries into single bullet points where appropriate.
- Drop internal implementation details that aren't useful to end users.
- Keep the press release concise — aim for the length of the sample provided.
- entries about "eterbug #NNNNN" are just tracking, mention only the app name.

Output ONLY the press release text, nothing else.
PROMPT_END
)

echo "$changelog_block" | CLAUDECODE= claude -p --model haiku "$prompt_text

Here is the changelog block to transform:
"

