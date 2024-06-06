#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt /usr/lib/s4a

case $(epm print info -e) in
    MOS*|ROSA*)
        add_unirequires libpangocairo-1.0.so.0 libXrender.so.1 libasound_module_pcm_pulse.so
        ;;
    ALTLinux/*)
        add_requires i586-alsa-plugins-pulse i586-libnsl1 i586-libXrandr i586-libpango
        ;;
esac

subst 's|/usr/lib/s4a/|/opt/S4A/|' usr/bin/s4a

add_libs_requires
