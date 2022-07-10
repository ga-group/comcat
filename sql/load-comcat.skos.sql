log_enable(2,1);
SPARQL CREATE SILENT GRAPH <http://data.ga-group.nl/comcat/>;
SPARQL CLEAR GRAPH <http://data.ga-group.nl/comcat/>;
CHECKPOINT;

DB.DBA.XML_SET_NS_DECL('stw', 'http://zbw.eu/stw/descriptor/', 1);
DB.DBA.XML_SET_NS_DECL('agrovoc', 'http://aims.fao.org/aos/agrovoc/', 1);
DB.DBA.XML_SET_NS_DECL('eurovoc', 'http://eurovoc.europa.eu/', 1);
DB.DBA.XML_SET_NS_DECL('wd', 'http://www.wikidata.org/entity/', 1);
DB.DBA.XML_SET_NS_DECL('ccat', 'http://data.ga-group.nl/comcat/', 1);

SPARQL LOAD <file:/comcat.skos.ttl> INTO <http://data.ga-group.nl/comcat/>;
CHECKPOINT;

SET u{GRAPH} http://data.ga-group.nl/comcat/;
LOAD 'sql/enrich-skos.sql';
