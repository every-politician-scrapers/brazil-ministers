const fs = require('fs');
let rawmeta = fs.readFileSync('../../meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  return `SELECT DISTINCT ?item ?name ?source ?sourceDate
            ?position ?positionLabel ?ministry ?ministryLabel ?start
           (STRAFTER(STR(?held), '/statement/') AS ?psid)
        WHERE {
          # Positions currently in the cabinet
          ?position p:P361 ?ps .
          ?ps ps:P361 wd:${meta.cabinet.parent} .
          FILTER NOT EXISTS { ?ps pq:P582 [] }

          OPTIONAL { ?position wdt:P2389 ?ministry }

          # Who currently holds those positions
          ?item wdt:P31 wd:Q5 ; p:P39 ?held .
          ?held ps:P39 ?position ; pq:P580 ?start .
          FILTER NOT EXISTS { ?held wikibase:rank wikibase:DeprecatedRank }
          OPTIONAL { ?held pq:P582 ?end }

          FILTER NOT EXISTS { ?held wikibase:rank wikibase:DeprecatedRank }
          FILTER (?start < NOW())
          FILTER (!BOUND(?end) || ?end > NOW())
          FILTER NOT EXISTS { ?item wdt:P570 [] }

          OPTIONAL {
            ?held prov:wasDerivedFrom ?ref .
            ?ref pr:P4656 ?source FILTER CONTAINS(STR(?source), 'en.wikipedia.org') .
            OPTIONAL { ?ref pr:P1810 ?sourceName }
            OPTIONAL { ?ref pr:P1932 ?statedName }
            OPTIONAL { ?ref pr:P813  ?sourceDate }
          }
          OPTIONAL { ?item rdfs:label ?wdLabel FILTER(LANG(?wdLabel) = "en") }
          BIND(COALESCE(?sourceName, ?wdLabel) AS ?name)

          SERVICE wikibase:label { bd:serviceParam wikibase:language "es,en" }
        }
        # ${new Date().toISOString()}
        ORDER BY STR(?name) STR(?position) ?began ?wdid ?sourceDate`
}
