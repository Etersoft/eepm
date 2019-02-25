
pkgdatadir=$(datadir)/eepm
# due using %makeinstallstd in spec
instpkgdatadir=$(pkgdatadir)

install:
	mkdir -p $(DESTDIR)$(bindir)/
	# breaks link
	cp -a `ls -1 bin/* | grep -v "[-_]"` $(DESTDIR)$(bindir)/
	cp -a bin/distr_info $(DESTDIR)$(bindir)/
	chmod 0755 $(DESTDIR)$(bindir)/*
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(instpkgdatadir)|g" \
		-e "s|CONFIGDIR=.*|CONFIGDIR=$(sysconfdir)/eepm|g" \
		-e "s|@VERSION@|$(version)|g" <bin/epm >$(DESTDIR)$(bindir)/epm
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(instpkgdatadir)|g" -e "s|@VERSION@|$(version)|g" <bin/serv >$(DESTDIR)$(bindir)/serv

	mkdir -p $(DESTDIR)$(pkgdatadir)/
	install -m 644 `ls -1 bin/* | grep "[-_]"` $(DESTDIR)$(pkgdatadir)/
	rm -f $(DESTDIR)$(pkgdatadir)/distr_info

	mkdir -p $(DESTDIR)$(mandir)/man1
	cp -a `ls -1 man/*` $(DESTDIR)$(mandir)/man1/
