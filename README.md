[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

comcat -- Taxonomy of traded commodities
========================================

The comcat taxonomy aims to allow for classification of traded commodities, whether listed as
standard contract on a futures exchange or traded OTC as a forward.  Taxons are assigned a
numeric code across up to four tiers of hierarchy: the class of commodity, the category within
the class, and the kind of commodity within the category, possibly extended with the sub-kind.

The taxonomy unifies other industry thesauri and vocabularies, such as FAO's agrovoc, various
tariff systems, or the STW thesaurus.  Alignment to these is provided.

The inclusion criterion is a list of traded commodities which is constantly monitored for the
purpose of regular revisions to the taxonomy.

The taxonomy is implemented as a SKOS thesaurus.


Why?
----

Diversified portfolios contain an array of products across all asset classes.  While there are
various classification systems for equity and debt instruments only few exist for commodities,
and none of them provides the depth needed for quant allocation strategies.


Where?
------

The [official github repository](https://github.com/ga-group/comcat/) contains the
published taxonomy.

For ease of access the latest versions of the taxonomy can be downloaded here:

- [comcat.skos.ttl](comcat.skos.ttl)

A hierarchical outline of all concepts can be found here:

- [tree](tree)
- [tree+def](tree+def) including definitions
