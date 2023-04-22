
pkgdatadir=$(datadir)/eepm

install: install_common install_epm install_serv install_yum

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
	cp -a etc/*.list $(DESTDIR)$(sysconfdir)/eepm/

	mkdir -p $(DESTDIR)$(mandir)/man1
	cp -a `ls -1 man/*` $(DESTDIR)$(mandir)/man1/


install_epm:
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(pkgdatadir)|g" \
		-e "s|CONFIGDIR=.*|CONFIGDIR=$(sysconfdir)/eepm|g" \
		-e "s|@VERSION@|$(version)|g" <bin/epm >$(DESTDIR)$(bindir)/epm

install_serv:
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(pkgdatadir)|g" \
		-e "s|CONFIGDIR=.*|CONFIGDIR=$(sysconfdir)/eepm|g" \
		-e "s|@VERSION@|$(version)|g" <bin/serv >$(DESTDIR)$(bindir)/serv

install_yum:
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(pkgdatadir)|g" \
		-e "s|CONFIGDIR=.*|CONFIGDIR=$(sysconfdir)/eepm|g" \
		-e "s|@VERSION@|$(version)|g" <bin/yum >$(DESTDIR)$(bindir)/yum


check:
	echo "test suite.."
