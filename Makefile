all:
	echo "We don't need any build"

installd_list = pack.d repack.d prescription.d play.d desktop.d
cmd_list = epm serv esu

.PHONY: all clean install check install_common $(installd_list) $(cmd_list)

# get version from the spec by default
PKGVER = $(shell grep "^Version: " eepm.spec | cut -d" " -f2)
PKGREL = $(shell grep "^Release: " eepm.spec | cut -d" " -f2)
version := $(PKGVER)-$(PKGREL)

pkgdatadir=$(datadir)/eepm

install: install_common $(installd_list) $(cmd_list)

install_common:
	mkdir -p $(DESTDIR)$(bindir)/

	# breaks link
	cp -a `ls -1 bin/* | grep -v "[-_]"` $(DESTDIR)$(bindir)/
	cp -a bin/distr_info $(DESTDIR)$(bindir)/
	chmod 0755 $(DESTDIR)$(bindir)/*

	mkdir -p $(DESTDIR)$(pkgdatadir)/
	cp -a `ls -1 bin/* | grep "[-_]"` $(DESTDIR)$(pkgdatadir)/
	rm -f $(DESTDIR)$(pkgdatadir)/distr_info

	mkdir -p $(DESTDIR)$(sysconfdir)/eepm/
	cp -a etc/eepm.conf $(DESTDIR)$(sysconfdir)/eepm/
	cp -a etc/serv.conf $(DESTDIR)$(sysconfdir)/eepm/
	cp -a etc/*.list $(DESTDIR)$(sysconfdir)/eepm/

	mkdir -p $(DESTDIR)$(mandir)/man1
	cp -a `ls -1 man/*` $(DESTDIR)$(mandir)/man1/

	mkdir -p $(DESTDIR)$(sysconfdir)/bash_completion.d/
	install -m 0644 bash_completion/serv $(DESTDIR)$(sysconfdir)/bash_completion.d/serv
	install -m 0644 bash_completion/eepm $(DESTDIR)$(sysconfdir)/bash_completion.d/eepm

	mkdir -p $(DESTDIR)$(datadir)/zsh/Completion/Linux/
	install -m 0644 zsh_completion/_eepm $(DESTDIR)$(datadir)/zsh/Completion/Linux/

	# shebang.req.files
	chmod a+x $(DESTDIR)$(pkgdatadir)/serv-*
	chmod a+x $(DESTDIR)$(pkgdatadir)/epm-*
	chmod a+x $(DESTDIR)$(pkgdatadir)/tools_*

	mkdir -p $(DESTDIR)/var/lib/eepm/
	mkdir -p $(DESTDIR)/var/cache/eepm/


$(cmd_list):
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(pkgdatadir)|g" \
		-e "s|CONFIGDIR=.*|CONFIGDIR=$(sysconfdir)/eepm|g" \
		-e "s|@VERSION@|$(version)|g" <bin/$@ >$(DESTDIR)$(bindir)/$@
	chmod 0755 $(DESTDIR)$(bindir)/$@

$(installd_list):
	mkdir -p $(DESTDIR)$(sysconfdir)/eepm/$@/
	cp $@/* $(DESTDIR)$(sysconfdir)/eepm/$@/
	chmod 0755 $(DESTDIR)$(sysconfdir)/eepm/$@/*.sh


check:
	echo "test suite.."
