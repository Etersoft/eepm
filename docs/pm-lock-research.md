# Package Manager Lock Research

## Lock Mechanism

### Lock Type
Both apt and rpm use **fcntl(2)** (POSIX locks), NOT flock(2):
- dpkg uses `lockf(3)` which wraps `fcntl(2)`
- rpm uses fcntl write lock on `/var/lib/rpm/.rpm.lock`

**Important**: `flock(1)` command uses `flock(2)` syscall which does NOT interact with fcntl locks!

### Lock Files

| System | Lock Files |
|--------|------------|
| ALT (apt-rpm) | `/var/lib/apt/lists/lock`, `/var/lib/rpm/.rpm.lock` |
| Ubuntu/Debian (apt-dpkg) | `/var/lib/dpkg/lock`, `/var/lib/dpkg/lock-frontend`, `/var/lib/apt/lists/lock` |
| RPM-based (yum/dnf) | `/var/lib/rpm/.rpm.lock` |

### Lock Detection

Locks are visible in `/proc/locks` as `POSIX ADVISORY WRITE`:
```
6239: POSIX  ADVISORY  WRITE 2276 00:31:264086 0 EOF
```

Detection methods:
1. **fuser -s /path/to/lock** - returns 0 if file is in use (works but shows open files, not just locks)
2. **/proc/locks** - parse for inode, shows actual locks
3. **Python fcntl.lockf()** with LOCK_NB - most accurate but requires Python
4. **lsof** - shows `W` flag for write locks

## Lock Timeout Support

### Ubuntu/Debian apt (1.8+)
Supports `DPkg::Lock::Timeout` option:
```bash
apt-get -o DPkg::Lock::Timeout=60 install package  # wait 60 seconds
apt-get -o DPkg::Lock::Timeout=-1 install package  # wait forever
```
Default: 120 seconds (`binary::apt::DPkg::Lock::Timeout "120"`)

### ALT apt-rpm
**Does NOT support** `DPkg::Lock::Timeout` - immediately fails if locked.

### RPM
No built-in lock wait mechanism.

## Recommendations for epm

Since ALT apt-rpm doesn't support lock timeout, epm should implement its own wait mechanism:

```sh
# Check if package manager is locked
__is_pm_locked() {
    case $PMTYPE in
        apt-rpm)
            sudorun fuser -s /var/lib/apt/lists/lock 2>/dev/null
            ;;
        apt-dpkg|aptitude-dpkg)
            sudorun fuser -s /var/lib/dpkg/lock-frontend 2>/dev/null
            ;;
        *-rpm)
            sudorun fuser -s /var/lib/rpm/.rpm.lock 2>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Wait for package manager lock with message
wait_for_pm_lock() {
    __is_pm_locked || return 0
    info "Waiting for package manager lock to be released..."
    while __is_pm_locked ; do
        sleep 2
    done
    info "Lock released, continuing..."
}
```

Call `wait_for_pm_lock` before apt-get/rpm commands in `epm_install_names` and `epm_ni_install_names`.

## Test Results

### Ubuntu 24.04
- fcntl lock on `/var/lib/dpkg/lock-frontend` blocks apt-get
- `DPkg::Lock::Timeout=-1` waits and succeeds after lock release
- `DPkg::Lock::Timeout=3` waits 3 seconds then returns error 100

### ALT Sisyphus (apt-rpm)
- fcntl lock on `/var/lib/apt/lists/lock` blocks apt-get
- `DPkg::Lock::Timeout` option is ignored
- Immediately returns error 100: "Невозможно заблокировать"

## References
- [apt-get lock mechanism](https://copyprogramming.com/howto/which-is-the-process-using-apt-get-lock)
- [rpm database locking](https://github.com/rpm-software-management/rpm-web/blob/master/problems/database.md)
- [flock vs fcntl](https://man7.org/linux/man-pages/man2/flock.2.html)
