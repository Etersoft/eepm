# Etersoft EPM package manager

Really, EPM is a wrapper for any package manager used in your operating system.

Run
```
$ epm --help
```
to see list of all supported commands.

The main goal of the project is to provide the same package management interface
on all platforms.

You can use
```
# epmi NAME
```
or
```
# epm -i NAME
```
or
```
# epm install NAME
```
to install a package. It is just an alias for one command: install the package.
EPM will run `urpmi` on Mandriva, `apt install` on Ubuntu, `yum install` on Fedora,
or `apt-get install` on ALT Linux.

And it has a little intelligence, so EPM will first try to install a package file via
low level commands (`rpm` or `dpkg`) before using higher level commands (`yum`, `apt`).

Just try your comfort style for package management and carry your experience the same
to any platform. EPM will print out the real command it uses so you can learn from it.

EPM has support for repository management: repo list, repo add, repo remove, update commands.

Also EPM contains `serv` command to control system services in system independed manner.

Pay attention to the following useful commands:
* `epmqf <command name>` - query package(s) owning file
* `epmqp <word>` - search in the list of installed packages

`epmqf` can be helpful to get package name for any file or command in the system:
```
$ epmqf epmqf
Note: epmqf is placed as /usr/bin/epmqf
 $ rpm -qf /usr/bin/epmqf
eepm-1.1.0-alt2
Note: /usr/bin/epmqf is link to epm
Note: epm is placed as /usr/bin/epm
 $ rpm -qf /usr/bin/epm
eepm-1.1.0-alt2
```

Also you can use
`epm play` to install the application from the official site.

For example, run `epm play edge` to install Microsoft Edge browser in your system.

## Install on any system

Just run under root user:
```
# curl -s https://raw.githubusercontent.com/Etersoft/eepm/master/packed/epm.sh | bash /dev/stdin ei --auto
```

If you have no `curl` on your system, just download file `https://raw.githubusercontent.com/Etersoft/eepm/master/packed/epm.sh`
and run in the download directory:
```
# bash epm.sh ei
```

## How to add new distro support
1. Fix detection with `distro_info`
2. Add distro support in `set_pm_type` function
3. Implement every command in epm-* files
4. Ensure that `epm packages` and `epm --short packages` works correctly
(`epm package 'awk'` have to print packages with `awk` substring in their names)

See detailed description in Russian at
http://wiki.etersoft.ru/Epm

Please e-mail if you have any questions:
`lav@etersoft.ru`
