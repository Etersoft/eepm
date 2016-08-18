#!/bin/sh
#
# Run for create one-file-scripts
#
# Copyright (C) 2012, 2016  Etersoft
# Copyright (C) 2012, 2016  Vitaly Lipatov <lav@etersoft.ru>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#


incorporate_subfile()
{
cat <<EOF >>$OUTPUT

internal_$1()
{
EOF

cat bin/$1 | grep -v "^#!/bin/sh" | sed -e "s| exit$| return|g" >>$OUTPUT

cat <<EOF >>$OUTPUT
}
EOF
}

get_version()
{
	grep "^Version:" eepm.spec | head -n1 | sed "s|Version: *||g"
}

filter_out()
{
	grep -v "^[ 	]*load_helper " | \
		sed -e 's|$SHAREDIR/tools_eget|internal_tools_eget|g' | \
		sed -e 's|DISTRVENDOR=$PROGDIR/distr_info|DISTRVENDOR=internal_distr_info|g' | \
		sed -e "s|@VERSION@|$(get_version)|g"

}

incorporate_all()
{
mkdir -p packed
OUTPUT=packed/$PACKCOMMAND.sh
echo -n >$OUTPUT
awk 'BEGIN{desk=0}{if(/^load_helper epm-sh-functions/){desk++};if(desk==0) {print}}' <bin/$PACKCOMMAND | filter_out >>$OUTPUT

for i in bin/epm-sh-functions $(ls -1 bin/$PACKCOMMAND-* | grep -v epm-sh-functions | sort) ; do
	echo
	echo "# File $i:"
	cat $i | grep -v "^#"
done | filter_out >>$OUTPUT

incorporate_subfile distr_info
incorporate_subfile tools_eget

awk 'BEGIN{desk=0}{if(desk>0) {print} ; if(/^load_helper epm-sh-functions/){desk++}}' <bin/$PACKCOMMAND | filter_out >>$OUTPUT
chmod 0755 $OUTPUT
}

###############
PACKCOMMAND=epm
incorporate_all

###############
PACKCOMMAND=serv
incorporate_all
