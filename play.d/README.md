
The main purpose of any play.d script is to download and to install a package.

Allowed variables:
* $SUDO (will filled with 'sudo' command when running without root privilegies

Allowed commands:
* epm (run the same epm called from)
* epm print info (instead of epm print info)
* epm tool eget (wget like utility)
* epm tool estrlist (string operations)

See any file for
. $(dirname $0)/common.sh
using

