
pkgdatadir=$(datadir)/eepm
# due using %makeinstallstd in spec
instpkgdatadir=/usr/share/eepm

install:
	mkdir -p $(DESTDIR)$(bindir)/
	# breaks link
	#install -m 755 `ls -1 bin/* | grep -v "-"` $(DESTDIR)$(bindir)/
	cp -a `ls -1 bin/* | grep -v "-"` $(DESTDIR)$(bindir)/
	chmod 0755 $(DESTDIR)$(bindir)/*
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(instpkgdatadir)|g" <bin/epm >$(DESTDIR)$(bindir)/epm
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(instpkgdatadir)|g" <bin/serv >$(DESTDIR)$(bindir)/serv

	mkdir -p $(DESTDIR)$(pkgdatadir)/
	install -m 644 `ls -1 bin/* | grep "-"` $(DESTDIR)$(pkgdatadir)/
