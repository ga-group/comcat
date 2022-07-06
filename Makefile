SHELL := /bin/zsh

sparql := /home/freundt/usr/apache-jena/bin/sparql
stardog := STARDOG_JAVA_ARGS='-Dstardog.default.cli.server=http://plutos:5820' /home/freundt/usr/stardog/bin/stardog

all: comcat.skos.ttl canon
check:
canon: .comcat.skos.ttl.canon

.%.ttl.canon: %.ttl
	rapper -i turtle $< >/dev/null
	ttl2ttl --sortable $< \
	| tr '@' '\001' \
	| sort -u \
	| tr '\001' '@' \
	| ttl2ttl -B \
	> $@ && mv $@ $< \
	&& touch $@

check.%: %.ttl shacl/%.shacl.ttl
	truncate -s 0 /tmp/$@.ttl
	$(stardog) data add --remove-all -g "http://data.ga-group.nl/catasess/" catasess $< $(ADDITIONAL)
	$(stardog) icv report --output-format PRETTY_TURTLE -g "http://data.ga-group.nl/catasess/" -r -l -1 catasess shacl/$*.shacl.ttl \
        >> /tmp/$@.ttl || true
	$(MAKE) $*.rpt

check.%: %.ttl shacl/%.shacl.sql
	$(RM) tmp/shacl-*.qry
	mawk 'BEGIN{f=0}/\f/{f++;next}{print>"tmp/shacl-"f".qry"}' $(filter %.sql, $^)
	truncate -s 0 /tmp/$@.ttl
	$(stardog) data add --remove-all -g "http://data.ga-group.nl/catasess/" catasess $< $(ADDITIONAL)
	for i in tmp/shacl-*.qry; do \
		$(stardog) query execute --format PRETTY_TURTLE -g "http://data.ga-group.nl/catasess/" -r -l -1 catasess $${i}; \
	done \
        >> /tmp/$@.ttl || true
	$(MAKE) $*.rpt

%.rpt: /tmp/check.%.ttl
	$(sparql) --results text --data $< --query sql/valrpt.sql


setup-stardog:                                                                                                                                                                                          
	$(stardog)-admin db create -o reasoning.sameas=OFF -n catasess
	$(stardog) namespace add --prefix cata --uri http://data.ga-group.nl/catasess/Catalogues/ catasess
	$(stardog) namespace add --prefix sess --uri http://data.ga-group.nl/catasess/TradingSessions/ catasess
	$(stardog) namespace add --prefix treg --uri http://data.ga-group.nl/catasess/TradingRegimes/ catasess

unsetup-stardog:
	$(stardog)-admin db drop catasess
