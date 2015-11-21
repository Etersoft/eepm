#!/bin/sh

../bin/epmqa --short >$0.0
# get two - packages list
cat $0.0 | grep ".*-.*-.*" | sort >$0.1
# try get their names, it does not have difference
cat $0.1 | ../bin/epm print name | sort >$0.1.1

cat $0.0 | ../bin/epm print name | sort >$0.2
