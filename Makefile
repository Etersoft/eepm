
pkgdatadir=$(datadir)/eepm
# due using %makeinstallstd in spec
instpkgdatadir=/usr/share/eepm

install: 
	mkdir -p $(DESTDIR)$(bindir)/
	mkdir -p $(DESTDIR)$(pkgdatadir)/
	install -m 755 `ls -1 bin/* | grep -v "-"` $(DESTDIR)$(bindir)/
	install -m 755 `ls -1 bin/* | grep "-"` $(DESTDIR)$(pkgdatadir)/
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(instpkgdatadir)|g" <bin/epm >$(DESTDIR)$(bindir)/epm
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(instpkgdatadir)|g" <bin/serv >$(DESTDIR)$(bindir)/serv

