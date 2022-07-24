SPARQL
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?code ?plbl
FROM <http://data.ga-group.nl/comcat/>
WHERE {
	[] a skos:Concept ;
		skos:notation ?code ;
		skos:prefLabel ?plbl .
}
ORDER BY ?code
;
