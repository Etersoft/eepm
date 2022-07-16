
The main purpose of any play.d script is download and install package.

Allowed variables:
* $DISTRVENDOR (distro_info utility)
* $SUDO

Allowed commands:
* epm (run the same epm called from)
* epm print info (instead of $DISTRVENDOR)
* epm tool eget (wget like utility)
* epm tool estrlist (string operations)

See any file for
. $(dirname $0)/common.sh
using

