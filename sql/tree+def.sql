SET BLOBS ON;
SPARQL
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT (CONCAT(SUBSTR("          ", 1, STRLEN(?code) - 2), "- #### ", ?code, "  ", ?plbl, "  (", GROUP_CONCAT(?albl; separator=", "), ")", "\n", SUBSTR("                    ", 1, STRLEN(?code)), GROUP_CONCAT(DISTINCT ?defn; separator="  ")) AS ?r)
FROM <http://data.ga-group.nl/comcat/>
WHERE {
	?x a skos:Concept ;
		skos:notation ?code ;
		skos:prefLabel ?plbl .
	OPTIONAL {
		?x skos:altLabel ?albl .
	}
	OPTIONAL {
		?x skos:definition ?defn .
	}
}
GROUP BY ?code ?plbl
ORDER BY ?code
;
