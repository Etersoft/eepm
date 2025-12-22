#!/bin/sh
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"
PKG="$4"

. $(dirname $0)/common.sh

# Ignore FreeBSD sonames from embedded binaries
ignore_lib_requires libc.so libc.so.7 libdl.so libm.so libstdc++.so libfuse.so.2

# Remove Ruby on Rails plugin templates with %namespaced_name% dirs
# (% in names conflicts with RPM macro syntax)
for dir in $BUILDROOT/opt/metasploit-framework/embedded/lib/ruby/gems/*/gems/railties-*/lib/rails/generators/rails/plugin/templates ; do
    [ -d "$dir" ] || continue
    relative_dir="${dir#$BUILDROOT}"
    remove_dir "$relative_dir"
done

# It installs to /opt/metasploit-framework with all dependencies bundled
