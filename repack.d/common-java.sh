#!/bin/sh

# Common code for repacking of JDK/JRE packages (Liberica, Axiom JDK)
# upstream packages register /usr/bin/java and so on via alternatives in %post scripts,
# we drop these scripts, so add ALT alternatives here

. $(dirname $0)/common.sh

__print_java_alt()
{
    local jvmdir="$1"
    local master="$2"
    local priority="$3"
    shift 3
    local i

    printf '%s\t%s\t%s\n' "/usr/bin/$master" "$jvmdir/bin/$master" "$priority"
    for i in "$@" ; do
        case "$i" in
            /*)
                printf '%s\t%s\t%s\n' "$i" "$jvmdir" "$jvmdir/bin/$master"
                ;;
            *)
                [ -x "$BUILDROOT$jvmdir/bin/$i" ] || continue
                printf '%s\t%s\t%s\n' "/usr/bin/$i" "$jvmdir/bin/$i" "$jvmdir/bin/$master"
                ;;
        esac
    done
}

# Usage: add_java_alternatives JVMDIR PRIORITY
# uses the same link sets as ALT openjdk packages
add_java_alternatives()
{
    local jvmdir="$1"
    local priority="$2"
    local name

    [ "$(epm print info -s)" = "alt" ] || return 0
    [ -x "$BUILDROOT$jvmdir/bin/java" ] || fatal "Can't find $jvmdir/bin/java"

    name="$(basename "$jvmdir")"

    __print_java_alt "$jvmdir" java "$priority" keytool rmiregistry jwebserver /usr/lib/jvm/jre | create_file "/etc/alternatives/packages.d/$name-java"

    [ -x "$BUILDROOT$jvmdir/bin/javac" ] || return 0
    __print_java_alt "$jvmdir" javac "$priority" jar jarsigner javadoc javap jdb serialver jconsole jinfo jmap jps jstack jstat jstatd jrunscript /usr/lib/jvm/java | create_file "/etc/alternatives/packages.d/$name-javac"
}

# JavaFX media links against multiple ffmpeg versions, none of them are available
ignore_java_ffmpeg_requires()
{
    ignore_lib_requires 'libavcodec.*' 'libavformat.*' 'libavcodec-ffmpeg.*' 'libavformat-ffmpeg.*'
}
