#!/bin/sh

incorporate_distr_info()
{
cat <<EOF >>$OUTPUT
internal_distr_info()
{
EOF

cat bin/distr_info >>$OUTPUT

cat <<EOF >>$OUTPUT
}
EOF
}

filter_out()
{
	grep -v "^load_helper" | sed -e 's|DISTRVENDOR=$PROGDIR/distr_info|DISTRVENDOR=internal_distr_info|g'
}

incorporate_all()
{
OUTPUT=$PACKCOMMAND-packed.sh
echo -n >$OUTPUT
awk 'BEGIN{desk=0}{if(/^load_helper epm-sh-functions/){desk++};if(desk==0) {print}}' <bin/$PACKCOMMAND >>$OUTPUT

for i in bin/epm-sh-functions $(ls -1 bin/$PACKCOMMAND-* | grep -v epm-sh-functions | sort) ; do
	echo
	echo "# File $i:"
	cat $i | grep -v "^#"
done | filter_out >>$OUTPUT

incorporate_distr_info

awk 'BEGIN{desk=0}{if(desk>0) {print} ; if(/^load_helper epm-sh-functions/){desk++}}' <bin/$PACKCOMMAND | filter_out >>$OUTPUT
}

###############
PACKCOMMAND=epm
incorporate_all

###############
PACKCOMMAND=serv
incorporate_all
