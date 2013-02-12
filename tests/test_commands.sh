#!/bin/sh

LOG=~/epm_test_log

cepm()
{
	echo
	epm --verbose $@ >> $LOG
}

log()
{
echo "$@" >> $LOG
}

cepm changelog mc

cepm filelist mc

cepm info mc

cepm -q mc

cepm -qf mc

cepm requires mc

# query packages
#cepm -qp mc

cepm remove nmap && log "nmap removed"

! cepm remove nmap && log "nmap doesnt installed"

cepm install --auto nmap && log "nmap installed"

cepm remove --auto nmap && log "nmap removed"

#cepm packages mc

#cepm search mc
