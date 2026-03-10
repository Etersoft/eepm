#!/bin/bash
# Smoke test for installed epm play applications
# Tests that apps actually launch, not just install
#
# Usage:
#   run-smoke-test.sh [app...]       - test specific apps
#   run-smoke-test.sh                - test all installed apps
#   run-smoke-test.sh --list-failed  - show failed tests

[ -n "$LOGDIR" ] || LOGDIR=~
SDIR=$LOGDIR/epm-smoke
FDIR=$LOGDIR/epm-filelist
mkdir -p "$SDIR"

[ -n "$EPM" ] || EPM=$(realpath $(dirname $0)/../bin/epm)

TIMEOUT_GUI=5
TIMEOUT_CLI=5
TIMEOUT_DAEMON=10

# apps that should not be tested (drivers, plugins, libraries, special)
SKIP_APPS="
aksusbd cnijfilter2 hplip-plugin virtualbox-extpack nwjs-ffmpeg-prebuilt
brother-ql brother-dcp kyocera-sane fplus-upd-ppd pantum-ppd ricoh-ppd
epson-inkjet-printer epson-printer-utility cups-bjnp
pantum-scanner kyocera-printer-driver
okular-csp
"

# daemon apps: "app port"
DAEMON_APPS="
lidarr 8686
radarr 7878
sonarr 8989
prowlarr 9696
bazarr 6767
jellyfin-server 8096
torrserver 8090
stirling-pdf 8080
angie 80
"

is_skip_app()
{
    echo "$SKIP_APPS" | grep -qw "$1"
}

get_daemon_port()
{
    echo "$DAEMON_APPS" | awk -v app="$1" '$1 == app {print $2}'
}

# Find executable for an app from its filelist
find_app_exec()
{
    local app="$1"
    local filelist="$FDIR/$app"
    [ -f "$filelist" ] || return 1

    # try .desktop file first
    local desktop
    desktop=$(grep '\.desktop$' "$filelist" | head -1)
    if [ -n "$desktop" ] && [ -f "$desktop" ] ; then
        local exec_line
        exec_line=$(grep '^Exec=' "$desktop" | head -1 | sed 's/^Exec=//')
        # strip field codes (%u %U %f %F etc)
        exec_line=$(echo "$exec_line" | sed 's/ %[fFuUdDnNickvm]//g')
        if [ -n "$exec_line" ] ; then
            # strip env prefix with variable assignments
            local clean_exec="$exec_line"
            while true ; do
                local first
                first=$(echo "$clean_exec" | awk '{print $1}')
                case "$first" in
                    env) clean_exec=$(echo "$clean_exec" | sed 's/^env //') ;;
                    *=*) clean_exec=$(echo "$clean_exec" | sed 's/^[^ ]* //') ;;
                    *) break ;;
                esac
            done
            # get the command (first word)
            local cmd
            cmd=$(echo "$clean_exec" | awk '{print $1}')
            local args
            args=$(echo "$clean_exec" | sed 's/^[^ ]*//')
            # resolve bare command name to full path
            if [ "${cmd#/}" = "$cmd" ] ; then
                if [ -x "/usr/bin/$cmd" ] ; then
                    cmd="/usr/bin/$cmd"
                elif grep -q "^/usr/bin/" "$filelist" ; then
                    cmd=$(grep '^/usr/bin/' "$filelist" | head -1)
                    args=""
                elif grep -q "^/opt/.*/$cmd\$" "$filelist" ; then
                    cmd=$(grep "^/opt/.*/$cmd\$" "$filelist" | head -1)
                    args=""
                fi
            fi
            # verify executable exists
            if [ ! -x "$cmd" ] ; then
                # fall through to /usr/bin and /opt/ search below
                :
            else
                echo "$cmd$args"
                return 0
            fi
        fi
    fi

    # try /usr/bin/ entries
    local bin
    bin=$(grep '^/usr/bin/' "$filelist" | head -1)
    if [ -n "$bin" ] && [ -x "$bin" ] ; then
        echo "$bin"
        return 0
    fi

    # try executable in /opt/
    bin=$(grep '^/opt/[^/]*/[^/]*$' "$filelist" | while read f ; do
        [ -f "$f" ] && [ -x "$f" ] && file -b "$f" | grep -q "ELF\|script" && echo "$f" && break
    done)
    if [ -n "$bin" ] ; then
        echo "$bin"
        return 0
    fi

    return 1
}

# Detect app type from filelist
detect_app_type()
{
    local app="$1"
    local filelist="$FDIR/$app"

    # check daemon list
    local port
    port=$(get_daemon_port "$app")
    [ -n "$port" ] && echo "daemon" && return

    [ -f "$filelist" ] || { echo "skip" ; return ; }

    # has .desktop file = GUI app
    if grep -q '\.desktop$' "$filelist" ; then
        echo "gui"
        return
    fi

    # has /usr/bin/ entry = CLI
    if grep -q '^/usr/bin/' "$filelist" ; then
        echo "cli"
        return
    fi

    echo "skip"
}

smoke_test_gui()
{
    local app="$1"
    local exec_cmd
    exec_cmd=$(find_app_exec "$app") || { echo "SKIP $app gui (no executable found)" ; return 0 ; }

    timeout --kill-after=3 $TIMEOUT_GUI \
        xvfb-run --auto-servernum --server-args="-screen 0 1280x1024x24" \
        $exec_cmd >"$SDIR/$app.stdout" 2>"$SDIR/$app.stderr"
    local rc=$?

    # 124 = timeout killed it (app was running = success)
    # 0 = app exited normally
    if [ "$rc" = 124 ] || [ "$rc" = 137 ] || [ "$rc" = 0 ] ; then
        echo "PASS $app gui"
        rm -f "$SDIR/$app.stdout" "$SDIR/$app.stderr"
        return 0
    fi

    # retry Electron apps with --no-sandbox
    if grep -q "v8_context_snapshot" "$FDIR/$app" 2>/dev/null ; then
        timeout --kill-after=3 $TIMEOUT_GUI \
            xvfb-run --auto-servernum --server-args="-screen 0 1280x1024x24" \
            $exec_cmd --no-sandbox >"$SDIR/$app.stdout" 2>"$SDIR/$app.stderr"
        rc=$?
        if [ "$rc" = 124 ] || [ "$rc" = 137 ] || [ "$rc" = 0 ] ; then
            echo "PASS $app gui (--no-sandbox)"
            rm -f "$SDIR/$app.stdout" "$SDIR/$app.stderr"
            return 0
        fi
    fi

    echo "FAIL $app gui (exit $rc)"
    return 1
}

smoke_test_daemon()
{
    local app="$1"
    local port
    port=$(get_daemon_port "$app")

    local exec_cmd
    exec_cmd=$(find_app_exec "$app") || { echo "SKIP $app daemon (no executable found)" ; return 0 ; }

    # start in background
    timeout --kill-after=3 $TIMEOUT_DAEMON $exec_cmd --nobrowser >"$SDIR/$app.stdout" 2>"$SDIR/$app.stderr" &
    local pid=$!
    sleep 3

    if [ -n "$port" ] ; then
        if curl -sf -o /dev/null "http://localhost:$port" 2>/dev/null ; then
            echo "PASS $app daemon (port $port)"
            kill $pid 2>/dev/null ; wait $pid 2>/dev/null
            rm -f "$SDIR/$app.stdout" "$SDIR/$app.stderr"
            return 0
        fi
    fi

    # check if process is still alive
    if kill -0 $pid 2>/dev/null ; then
        echo "PASS $app daemon (running)"
        kill $pid 2>/dev/null ; wait $pid 2>/dev/null
        rm -f "$SDIR/$app.stdout" "$SDIR/$app.stderr"
        return 0
    fi

    wait $pid 2>/dev/null
    echo "FAIL $app daemon (crashed)"
    return 1
}

smoke_test_cli()
{
    local app="$1"
    local exec_cmd
    exec_cmd=$(find_app_exec "$app") || { echo "SKIP $app cli (no executable found)" ; return 0 ; }

    # try --version, then --help, then -V
    for flag in --version --help -V ; do
        timeout $TIMEOUT_CLI $exec_cmd $flag >/dev/null 2>&1
        local rc=$?
        if [ "$rc" = 0 ] ; then
            echo "PASS $app cli ($flag)"
            return 0
        fi
    done

    # just try to run it (some CLI tools exit 0 with no args)
    timeout $TIMEOUT_CLI $exec_cmd >/dev/null 2>&1
    local rc=$?
    if [ "$rc" = 0 ] || [ "$rc" = 124 ] ; then
        echo "PASS $app cli"
        return 0
    fi

    echo "FAIL $app cli (exit $rc)"
    return 1
}

smoke_test_app()
{
    local app="$1"

    is_skip_app "$app" && { echo "SKIP $app (blacklist)" ; return 0 ; }

    local apptype
    apptype=$(detect_app_type "$app")

    case "$apptype" in
        gui)    smoke_test_gui "$app" ;;
        daemon) smoke_test_daemon "$app" ;;
        cli)    smoke_test_cli "$app" ;;
        skip)   echo "SKIP $app (no filelist or unclassified)" ;;
    esac
}

# --list-failed mode
if [ "$1" = "--list-failed" ] ; then
    grep "^FAIL " "$SDIR/results.txt" 2>/dev/null
    exit
fi

# main
RESULTS="$SDIR/results.txt"
> "$RESULTS"

PASS=0
FAIL=0
SKIP=0

if [ -n "$1" ] ; then
    apps="$@"
else
    apps=$(ls "$FDIR"/ | grep -v '=')
fi

for app in $apps ; do
    result=$(smoke_test_app "$app")
    echo "$result"
    echo "$result" >> "$RESULTS"
    case "$result" in
        PASS*) PASS=$((PASS + 1)) ;;
        FAIL*) FAIL=$((FAIL + 1)) ;;
        SKIP*) SKIP=$((SKIP + 1)) ;;
    esac
done

echo
echo "=== Summary: PASS=$PASS FAIL=$FAIL SKIP=$SKIP ==="
