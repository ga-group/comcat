PREFIX sh: <http://www.w3.org/ns/shacl#>

SELECT ?sch ?sev (COUNT(?r) AS ?cnt) WHERE {
	?x a sh:ValidationReport ;
		sh:result ?r .
	?r sh:sourceShape ?sh ;
		sh:resultSeverity ?sev .
	OPTIONAL {
		?r sh:sourceConstraint ?sc
	}
	BIND(COALESCE(?sc, ?sh) AS ?sch)
} GROUP BY ?sch ?sev ORDER BY ?sch ?sev
