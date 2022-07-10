echo "Materialising skos, using <"$u{GRAPH}">\n";

SPARQL
DEFINE sql:log-enable 3
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
WITH <$u{GRAPH}>
INSERT {
	?x skos:narrower ?y
} WHERE {
	?y skos:broader ?x
};

SPARQL
DEFINE sql:log-enable 3
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
WITH <$u{GRAPH}>
INSERT {
	?x skos:broadMatch ?y
} WHERE {
	?y skos:narrowMatch ?x
};

SPARQL
DEFINE sql:log-enable 3
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
WITH <$u{GRAPH}>
INSERT {
	?x skos:hasTopConcept ?y
} WHERE {
	?y skos:topConceptOf ?x
};

CHECKPOINT;
