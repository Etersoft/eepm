MSGFMT = msgfmt -v
MSGMERGE = msgmerge
MSGMERGE_UPDATE = msgmerge --update
MSGINIT = msginit

PROJECT = eepm
LANGUAGES = ru

SCRIPTLIST = $(shell find ../bin ../pack.d ../play.d ../repack.d -type f 2>/dev/null)

all: $(LANGUAGES:%=%.mo)

# for local testing: creates locale directory structure
local: $(LANGUAGES:%=%.mo)
	@for lang in $(LANGUAGES); do \
	    mkdir -p $$lang/LC_MESSAGES; \
	    cp $$lang.mo $$lang/LC_MESSAGES/$(PROJECT).mo; \
	done

%.mo: %.po
	$(MSGFMT) -c -o t-$@ $< && mv t-$@ $@

$(PROJECT).pot: $(SCRIPTLIST) Makefile extract-help.sh
	xgettext --keyword=info --keyword=fatal --keyword=warning \
	         --keyword=debug --keyword=message --keyword=confirm_action \
	         --keyword=confirm_info --keyword=eval_gettext --keyword=echog \
	         -o $@.tmp --language=Shell --from-code=utf-8 $(SCRIPTLIST)
	./extract-help.sh > help.pot.tmp
	msgcat $@.tmp help.pot.tmp -o $@
	rm -f $@.tmp help.pot.tmp

update-po: $(PROJECT).pot
	@for lang in $(LANGUAGES); do \
	    if [ -f $$lang.po ]; then \
	        $(MSGMERGE_UPDATE) $$lang.po $<; \
	    else \
	        $(MSGINIT) -i $< -o $$lang.po -l $$lang --no-translator; \
	    fi; \
	done

install: $(LANGUAGES:%=%.mo)
	@for lang in $(LANGUAGES); do \
	    install -D $$lang.mo $(DESTDIR)$(datadir)/locale/$$lang/LC_MESSAGES/$(PROJECT).mo; \
	done

clean:
	rm -f *.mo
	rm -rf $(LANGUAGES:%=%/LC_MESSAGES)
