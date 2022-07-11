SHELL := /bin/zsh

sparql := /home/freundt/usr/apache-jena/bin/sparql
stardog := STARDOG_JAVA_ARGS='-Dstardog.default.cli.server=http://plutos:5820' /home/freundt/usr/stardog/bin/stardog

all: comcat.skos.ttl canon imported
check: check.comcat.skos
canon: .comcat.skos.ttl.canon
imported: .imported.comcat.skos

-include secrets.mk
csvsql := isql $(ISQL_HOST) $(ISQL_USER) $(ISQL_PASS) BANNER=ON CSV=ON VERBOSE=OFF PROMPT=OFF CSV_FIELD_SEPARATOR='	'

.%.ttl.canon: %.ttl
	rapper -i turtle $< >/dev/null
	ttl2ttl --sortable $< \
	| tr '@' '\001' \
	| sort -u \
	| tr '\001' '@' \
	| ttl2ttl -B \
	> $@ && mv $@ $< \
	&& touch $@

.imported.%: sql/load-%.sql %.ttl
	$(csvsql) $< \
	&& touch $@

check.%: %.ttl shacl/%.shacl.ttl
	truncate -s 0 /tmp/$@.ttl
	$(stardog) data add --remove-all -g "http://data.ga-group.nl/comcat/" comcat $< $(ADDITIONAL)
	$(stardog) icv report --output-format PRETTY_TURTLE -g "http://data.ga-group.nl/comcat/" -r -l -1 comcat shacl/$*.shacl.ttl \
        >> /tmp/$@.ttl || true
	$(MAKE) $*.rpt

check.%: %.ttl shacl/%.shacl.sql
	$(RM) tmp/shacl-*.qry
	mawk 'BEGIN{f=0}/\f/{f++;next}{print>"tmp/shacl-"f".qry"}' $(filter %.sql, $^)
	truncate -s 0 /tmp/$@.ttl
	$(stardog) data add --remove-all -g "http://data.ga-group.nl/comcat/" comcat $< $(ADDITIONAL)
	for i in tmp/shacl-*.qry; do \
		$(stardog) query execute --format PRETTY_TURTLE -g "http://data.ga-group.nl/comcat/" -r -l -1 comcat $${i}; \
	done \
        >> /tmp/$@.ttl || true
	$(MAKE) $*.rpt

%.rpt: /tmp/check.%.ttl
	$(sparql) --results text --data $< --query sql/valrpt.sql


setup-stardog:                                                                                                                                                                                          
	$(stardog)-admin db create -o reasoning.sameas=OFF -n comcat
	$(stardog) namespace add --prefix ccat --uri http://data.ga-group.nl/comcat/ comcat

unsetup-stardog:
	$(stardog)-admin db drop comcat
