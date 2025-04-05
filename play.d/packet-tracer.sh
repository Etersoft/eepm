#!/bin/sh

PKGNAME=PacketTracer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Cisco PacketTracer"
URL="https://www.sysnettechsolutions.com/en/download-cisco-packet-tracer/"

. $(dirname $0)/common.sh

# Closed by Cisco
case $VERSION in
    7.3.0)
        # libbz2.so.1.0 libdouble-conversion.so.1
        PKGURL="ipfs://QmS2VMR1vxoKxyUwKb4TZkLWtwsKM9ciDzC8xT8KTuuceE?filename=PacketTracer_730_amd64.deb"
        ;;
    7.3.1)
        PKGURL="ipfs://QmQD3N16qCXBLNC6LhYWmJrh8U4Qd1kJm2T6Lwuq7sf7ms?filename=PacketTracer_731_amd64.deb"
        ;;
    8.0|8.0.0)
        PKGURL="ipfs://QmZYdJ1ew9dnkHjMddMRHa1hpRdnSfuChRd4RNWzFnaPuu?filename=PacketTracer_800_amd64_build212_final.deb"
        ;;
    8.0.1)
        PKGURL="ipfs://Qmar3FaQM8oZYErPWgWJGpvimV8gSvur6Q3Dhfet4M3C4s?filename=CiscoPacketTracer_801_Ubuntu_64bit.deb"
        ;;
    8.1.0)
        PKGURL="ipfs://QmQRDeam5nsYxFmcya6GeK78VWyBUdDjWB4gqcMG7ATL6W?filename=CiscoPacketTracer_810_Ubuntu_64bit.deb"
        ;;
    8.1.1)
        PKGURL="ipfs://QmQXVKTvHAJanzT441pFKNZ6DnHxEESjEzLt21io33JyYv?filename=CiscoPacketTracer_811_Ubuntu_64bit.deb"
        ;;
    8.2|8.2.0)
        PKGURL="ipfs://QmU11PAoS7rpFdEnQAH5xW7sLDP4dpua9HbPXVenKwQVoP?filename=CiscoPacketTracer_820_Ubuntu_64bit.deb"
        ;;
    *|8.2.1)
        PKGURL="ipfs://QmWo3kUEnwm9oUTRmgwFFXPMeoPx44CF6kphKnoRMi2m6n?filename=CiscoPacketTracer_821_Ubuntu_64bit.deb"
        ;;
esac

install_pkgurl
