installd_list = pack.d repack.d prescription.d play.d
cmd_list = epm serv yum

.PHONY: all clean install check install_common install_epm install_serv install_yum $(installd_list) $(cmd_list)

pkgdatadir=$(datadir)/eepm

install: install_common install_epm install_serv install_yum $(installd_list) $(cmd_list)

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

$(cmd_list):
	sed -e "s|SHAREDIR=.*|SHAREDIR=$(pkgdatadir)|g" \
		-e "s|CONFIGDIR=.*|CONFIGDIR=$(sysconfdir)/eepm|g" \
		-e "s|@VERSION@|$(version)|g" <bin/$@ >$(DESTDIR)$(bindir)/$@

$(installd_list):
	mkdir -p $(DESTDIR)$(sysconfdir)/eepm/$@/
	cp repack.d/* $(DESTDIR)$(sysconfdir)/eepm/$@/
	chmod 0755 $(DESTDIR)$(sysconfdir)/eepm/$@/*.sh


check:
	echo "test suite.."
