SHELL := /bin/zsh

sparql := /home/freundt/usr/apache-jena/bin/sparql
stardog := STARDOG_JAVA_ARGS='-Dstardog.default.cli.server=http://plutos:5820' /home/freundt/usr/stardog/bin/stardog

all: comcat.skos.ttl canon imported tree.md tree+def.md
check: check.comcat.skos
canon: .comcat.skos.ttl.canon
imported: .imported.comcat.skos

-include secrets.mk
csvsql := isql $(ISQL_HOST) $(ISQL_USER) $(ISQL_PASS) BANNER=ON CSV=ON VERBOSE=OFF PROMPT=OFF CSV_FIELD_SEPARATOR='	'
txtsql := isql $(ISQL_HOST) $(ISQL_USER) $(ISQL_PASS) BANNER=OFF CSV=OFF VERBOSE=OFF PROMPT=OFF

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
	$(csvsql) $(filter %.sql, $^)
	$(stardog) data add --remove-all -g "http://data.ga-group.nl/comcat/" comcat $(filter %.ttl, $^)
	touch $@

check.%: %.ttl shacl/%.shacl.ttl .imported.%
	truncate -s 0 /tmp/$@.ttl
	$(stardog) icv report --output-format PRETTY_TURTLE -g "http://data.ga-group.nl/comcat/" -r -l -1 comcat shacl/$*.shacl.ttl \
        >> /tmp/$@.ttl || true
	$(MAKE) $*.rpt

check.%: %.ttl shacl/%.shacl.sql .imported.%
	$(RM) tmp/shacl-*.qry
	mawk 'BEGIN{f=0}/\f/{f++;next}{print>"tmp/shacl-"f".qry"}' $(filter %.sql, $^)
	truncate -s 0 /tmp/$@.ttl
	for i in tmp/shacl-*.qry; do \
		$(stardog) query execute --format PRETTY_TURTLE -g "http://data.ga-group.nl/comcat/" -r -l -1 comcat $${i}; \
	done \
        >> /tmp/$@.ttl || true
	$(MAKE) $*.rpt

%.rpt: /tmp/check.%.ttl
	$(sparql) --results text --data $< --query sql/valrpt.sql

tmp/%.out: sql/%.sql .imported.comcat.skos
	$(txtsql) $< \
	> $@.t && mv $@.t $@

tmp/%.csv: sql/%.sql .imported.comcat.skos
	$(csvsql) $< \
	> $@.t && mv $@.t $@

export.void: tmp/comcat.skos.void
	-mawk '(x+=$$0=="")<=3&&($$0==""||(x=0)||1)' void.ttl > $@
	@echo >> $@
	@echo "## with summaries" >> $@
	cat $^ \
	>> $@ && mv $@ void.ttl

tmp/%.void: .imported.%
	for i in sql/void-*.sql; do \
		$(stardog) query execute --format PRETTY_TURTLE -g "http://data.ga-group.nl/comcat/" -r -l -1 comcat $${i}; \
	done \
	| ttl2ttl --sortable --expand-generic \
	| sed 's@<urn:sha1:\([0-9a-f]*\)>@ _:b\1@; s/rdf:type\t/a\t/; /^@/d' \
	| sort -u \
	| ttl2ttl -B \
	> $@


define header
comcat tree
===========

endef
export header
tree.md: tmp/tree.out
	mawk -v header="$$header" 'BEGIN{print header}{sub("\(\)","",$$0)}1' < $< \
	> $@.t && mv $@.t $@
tree+def.md: tmp/tree+def.out
	mawk -v header="$$header" 'BEGIN{print header}{sub("\(\)","",$$0)}1' < $< \
	| sed 's@%\([[:xdigit:]]\{2\}\)@\&x\1;@g' \
	> $@.t && mv $@.t $@

tmp/comcat.html: comcat.skos.ttl
	skos-play hierarchical -f html -i $< -o $@ -s unesco -l en


setup-stardog:
	$(stardog)-admin db create -o reasoning.sameas=OFF -n comcat
	$(stardog) namespace add --prefix ccat --uri http://data.ga-group.nl/comcat/ comcat

unsetup-stardog:
	$(stardog)-admin db drop comcat
