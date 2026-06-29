#!/bin/sh

SUPPORTEDARCHES=''
DESCRIPTION="Install GStreamer media codecs (libav/ffmpeg and good/bad/base plugins)"
[ "$1" != "--run" ] && echo "$DESCRIPTION" && exit

. $(dirname $0)/common.sh

# GStreamer codec package names differ per distribution.
case "$(epm print info -p)" in
    deb)
        pkgs="gstreamer1.0-libav gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-ugly"
        ;;
    rpm)
        case "$(epm print info -s)" in
            alt)
                pkgs="gst-libav gst-plugins-good gst-plugins-bad gst-plugins-base gstreamer"
                ;;
            *)
                # On Fedora/RHEL-like (RED OS, Rosa) the libav (ffmpeg) plugin is not in
                # the base repositories, so install only the plugins available there.
                pkgs="gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-base"
                ;;
        esac
        ;;
    *)
        info "GStreamer codec prescription is not defined for this package system, skipping."
        exit 0
        ;;
esac

epm install --skip-installed $pkgs
