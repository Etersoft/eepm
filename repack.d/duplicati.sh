#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_requires mono-full libgtk-sharp2

subst '1iBuildRequires: rpm-build-python3' $SPEC
subst '1i%add_python3_path /usr/lib/duplicati' $SPEC

subst '1iAutoProv: no' $SPEC
subst '1iAutoReq: yes,nomonolib,nomono' $SPEC

subst 's|env python.*|env python3|' $BUILDROOT/usr/lib/duplicati/utility-scripts/DuplicatiVerify.py
subst 's|/usr/bin/bash|/bin/bash|' $BUILDROOT/usr/lib/duplicati/{lvm-scripts/*.sh,run-script-example.sh} $BUILDROOT/usr/bin/{duplicati-server,duplicati-cli,duplicati}

epm install --skip-installed rpm-build-python3 mono-full libgtk-sharp2
