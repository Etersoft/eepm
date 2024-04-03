MSGFMT = msgfmt -v
MSGMERGE = msgmerge
MSGMERGE_UPDATE = msgmerge --update
MSGINIT = msginit
MSGCONV = msgconv
MSGFILTER = msgfilter

SCRIPTLIST = $(shell for i in bin pack.d play.d repack.d ; do find ../$$i -type f ; done)

PROJECT = eepm
LANGUAGE = ru

all: $(PROJECT).mo
	

$(PROJECT).mo: $(PROJECT).po
	$(MSGFMT) -c -o t-$@ $< && mv t-$@ $@

$(PROJECT).pot: $(SCRIPTLIST) Makefile
	echo $(SCRIPTLIST) | xargs xgettext -a -o $@ --language Shell --from-code=utf-8 $^

$(PROJECT).po: $(PROJECT).pot
	$(MSGMERGE_UPDATE) $@ $<

install: $(PROJECT).mo
	install -D $< $(DESTDIR)$(datadir)/locale/$(LANGUAGE)/LC_MESSAGES/$<

clean:
	rm -f $(PROJECT).mo
