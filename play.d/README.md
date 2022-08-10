
The main purpose of any play.d script is to download and to install a package.

Allowed variables:
* $DISTRVENDOR (distro_info utility) (legacy, use epm print info instead of)
* $SUDO (will filled with 'sudo' command when running without root privilegies

Allowed commands:
* epm (run the same epm called from)
* epm print info (instead of $DISTRVENDOR)
* epm tool eget (wget like utility)
* epm tool estrlist (string operations)

See any file for
. $(dirname $0)/common.sh
using

