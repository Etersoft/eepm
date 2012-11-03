#!/bin/sh

cepm()
{
	echo
	../bin/epm --verbose $@ >/dev/null
}

cepm changelog mc

cepm filelist mc

cepm info mc

cepm -q mc

cepm -qf mc

cepm requires mc

# query packages
#cepm -qp mc

#cepm install mc

#cepm packages mc

#cepm search mc
