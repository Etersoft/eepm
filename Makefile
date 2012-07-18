
pkgdatadir=$(datadir)/eterbuild

install: 
	mkdir -p $(DESTDIR)$(bindir)
	install -m 755 bin/* $(DESTDIR)$(bindir)
