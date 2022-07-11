PREFIX void: <http://rdfs.org/ns/void#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix afn: <http://jena.hpl.hp.com/arq/function#>
prefix fn:  <http://www.w3.org/2005/xpath-functions#>
PREFIX ov:  <http://open.vocab.org/terms/>

CONSTRUCT {
	?dataset a void:Dataset ;
		void:classPartition ?part .
	?part void:class rdfs:Resource ;
		void:entities ?instances .
}
WHERE {
	BIND(<http://data.ga-group.nl/comcat/Dataset> AS ?dataset)
	{
	SELECT (COUNT(DISTINCT ?s) AS ?instances)
	WHERE {
        	?s ?p ?o .
		OPTIONAL { ?s a ?type }
		FILTER (!BOUND(?type))
	}
	}
	BIND(IRI(CONCAT('urn:sha1:',SHA1(CONCAT("http://data.ga-group.nl/comcat/",STR(rdfs:Resource))))) AS ?part)
	FILTER(?instances > 0)
}

