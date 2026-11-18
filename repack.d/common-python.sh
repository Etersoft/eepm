#!/bin/sh

# common functions for repacking python packages

. $(dirname $0)/common.sh

# Move python site-packages/dist-packages to the current system python site directory
fix_python_path()
{
    local py_sys_site=$(python3 -c 'import sysconfig; print(sysconfig.get_path("purelib") or "")' 2>/dev/null)
    [ -n "$py_sys_site" ] || py_sys_site=$(python3 -c 'import sys; print("/usr/lib/python%d.%d/site-packages" % sys.version_info[:2])' 2>/dev/null)
    [ -n "$py_sys_site" ] || return 0
    local py_ext_suffix=$(python3 -c 'import sysconfig; print(sysconfig.get_config_var("EXT_SUFFIX") or "")' 2>/dev/null)
    local found_site

    for found_site in $(find "$BUILDROOT" -type d \( -path "*/python3.*/site-packages" -o -path "*/python*/dist-packages" \) 2>/dev/null | sed "s|^$BUILDROOT||") ; do
        # Directory layout may differ (lib/lib64 or site/dist-packages) even
        # when the Python ABI matches. Check CPython's version/platform tag.
        if find "$BUILDROOT$found_site" -type f -name "*.cpython-*.so" ! -name "*$py_ext_suffix" 2>/dev/null | grep -q .; then
            fatal "Python ABI mismatch"
        fi
        if [ -z "$py_ext_suffix" ] && find "$BUILDROOT$found_site" -type f -name "*.cpython-*.so" 2>/dev/null | grep -q .; then
            fatal "Cannot determine Python ABI"
        fi

        [ "$found_site" = "$py_sys_site" ] && continue

        info "Fixing python path: $found_site -> $py_sys_site"
        move_dir "$found_site" "$py_sys_site"

        local parent_dir=$(dirname "$found_site")
        [ -d "$BUILDROOT$parent_dir" ] && is_dir_empty "$BUILDROOT$parent_dir" && remove_dir "$parent_dir"
    done
}

# Detect the Python package naming convention once per scan.
__python_requires_prefix()
{
    local packages prefix
    packages=$(epm search --short 'python*' 2>/dev/null) || return 0
    for prefix in python3- python-module- python-; do
        if printf '%s\n' "$packages" | grep -q "^$prefix"; then
            echo "$prefix"
            return
        fi
    done
}

# get python requires
get_python_requires()
{
    local fdir="$BUILDROOT"

    local LANG=C
    local python_prefix
    if [ "$(epm print info -s)" = "alt" ]; then
        python_prefix='python3('
    else
        python_prefix=$(__python_requires_prefix)
        [ -n "$python_prefix" ] || warning 'Cannot determine Python package prefix'
    fi

    # Keep standard library modules out of generated package requires.
    local STD_LIBS="abc|argparse|asyncio|base64|calendar|collections|contextlib|copy|csv|datetime|enum|errno|fcntl|functools|gc|getopt|gettext|glob|hashlib|importlib|inspect|io|itertools|json|locale|logging|math|multiprocessing|os|pathlib|pickle|platform|posix|pwd|queue|random|re|selectors|shlex|shutil|signal|site|socket|sqlite3|ssl|stat|string|subprocess|sys|tarfile|tempfile|threading|time|traceback|types|typing|unittest|urllib|uuid|warnings|weakref|webbrowser|xml|zipfile"

    local INTERNAL_PKGS=$(find "$fdir" -type d \( -path "*/site-packages/*" -o -path "*/dist-packages/*" \) -not -path "*/__pycache__*" 2>/dev/null | sed -E 's#.*/(site|dist)-packages/([^/]+).*#\2#' | sort -u)

    if [ -z "$INTERNAL_PKGS" ]; then
        INTERNAL_PKGS=$(basename "$(realpath "$fdir")")
    fi

    # false positive pyside
    local IGNORE_EXTRA="shiboken6|shiboken"

    # Combine everything into the exclude pattern
    local PKG_PATTERN=$(echo "$INTERNAL_PKGS" | tr '\n' '|' | sed 's/|$//')
    local EXCLUDE_PATTERN="^($STD_LIBS|$PKG_PATTERN|$IGNORE_EXTRA|gi)$"

    # Python modules
    grep -rhE "^\s*(import|from)\s+[a-zA-Z0-9_]" "$fdir" --include="*.py" 2>/dev/null | \
        sed -E 's/^\s*from\s+([a-zA-Z0-9_]+).*/\1/; s/^\s*import\s+//' | \
        tr ',' '\n' | \
        sed -E 's/^\s*//; s/\s+as\s+.*//; s/\..*//; s/\s.*//' | \
        grep -vE "$EXCLUDE_PATTERN" | \
        sort -u | \
        while read -r lib; do
            [ -n "$lib" ] || continue
            case "$python_prefix" in
                'python3(') echo "python3($lib)" ;;
                '') ;;
                *) printf '%s%s\n' "$python_prefix" "$(printf '%s' "$lib" | tr '[:upper:]_' '[:lower:]-')" ;;
            esac
        done

    # GObject Typelibs
    {
        grep -rhE "gi\.require_version\(['\"][a-zA-Z0-9_]+" "$fdir" --include="*.py" 2>/dev/null | \
            sed -E "s/.*gi\.require_version\(['\"]([a-zA-Z0-9_]+).*/\1/"

        grep -rh "from gi.repository import" "$fdir" --include="*.py" 2>/dev/null | \
            sed -E 's/#.*//' | sed -E 's/.*import\s+//' | tr ',' '\n' | \
            sed -E 's/^\s*//; s/\s+as\s+.*//; s/\s.*//' | grep -E '^[A-Z]'
    } | sort -u | while read -r lib; do
        [ -n "$lib" ] && echo "typelib($lib)"
    done
}

__filter_python_requires()
{
    local reqs_file
    reqs_file=$(mktemp) || fatal

    cat >"$reqs_file"

    if [ -f "$BUILDROOT/.eepm_filter_python_requires" ] ; then
        grep -vE -f "$BUILDROOT/.eepm_filter_python_requires" "$reqs_file" >"$reqs_file.new"
        mv "$reqs_file.new" "$reqs_file"
    fi

    cat "$reqs_file"
    rm -f "$reqs_file"
}

# cancel adding python requires
stop_python_requires()
{
    touch "$BUILDROOT/.eepm_stop_python_requires"
}

add_python_requires()
{
    [ -f "$BUILDROOT/.eepm_stop_python_requires" ] && return 0

    local ll
    [ -n "$nodeps" ] && info "Skipping any requires detection ..." && return
    info "Scanning for required python modules ..."
    get_python_requires | __filter_python_requires | while read ll ; do
        [ -n "$ll" ] || continue
        info "Requires: $ll"
        add_directrequires "$ll" </dev/null
    done
}

filter_from_python_requires()
{
   echo "$@" | xargs -n1 >> "$BUILDROOT/.eepm_filter_python_requires"
}
