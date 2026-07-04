all:
	echo "We don't need any build"

installd_list = pack.d repack.d prescription.d play.d desktop.d desktop-manager.d
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
	mkdir -p $(DESTDIR)$(sysconfdir)/eepm/conf.d/

	mkdir -p $(DESTDIR)$(mandir)/man1
	cp -a `ls -1 man/*` $(DESTDIR)$(mandir)/man1/

	mkdir -p $(DESTDIR)$(sysconfdir)/bash_completion.d/
	install -m 0644 completions/bash/serv $(DESTDIR)$(sysconfdir)/bash_completion.d/serv
	install -m 0644 completions/bash/eepm $(DESTDIR)$(sysconfdir)/bash_completion.d/eepm

	mkdir -p $(DESTDIR)$(datadir)/zsh/Completion/Linux/
	install -m 0644 completions/zsh/_serv $(DESTDIR)$(datadir)/zsh/Completion/Linux/
	install -m 0644 completions/zsh/_eepm $(DESTDIR)$(datadir)/zsh/Completion/Linux/

	mkdir -p $(DESTDIR)$(datadir)/fish/vendor_completions.d/
	cp -a completions/fish/*pm*.fish $(DESTDIR)$(datadir)/fish/vendor_completions.d/
	chmod 0644 $(DESTDIR)$(datadir)/fish/vendor_completions.d/*pm*.fish

	# command-not-found hooks
	mkdir -p $(DESTDIR)$(sysconfdir)/profile.d/
	install -m 0644 etc/profile.d/epm-command-not-found.sh $(DESTDIR)$(sysconfdir)/profile.d/
	mkdir -p $(DESTDIR)$(sysconfdir)/zsh/
	install -m 0644 etc/zsh/epm-command-not-found.zsh $(DESTDIR)$(sysconfdir)/zsh/
	mkdir -p $(DESTDIR)$(sysconfdir)/fish/conf.d/
	install -m 0644 etc/fish/conf.d/epm-command-not-found.fish $(DESTDIR)$(sysconfdir)/fish/conf.d/

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
	chmod 0755 $(DESTDIR)$(sysconfdir)/eepm/$@/*.sh 2>/dev/null || :


check:
	echo "test suite.."
