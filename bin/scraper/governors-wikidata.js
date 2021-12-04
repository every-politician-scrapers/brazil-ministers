module.exports = function () {
  return `
    SELECT DISTINCT ?state ?stateLabel ?position ?positionLabel ?person ?personLabel ?start 
             (STRAFTER(STR(?held), '/statement/') AS ?psid)
    WHERE {
      ?state wdt:P31 wd:Q485258 .
      MINUS { ?state wdt:P576 [] }
      OPTIONAL {
        ?state wdt:P1313 ?position .
        OPTIONAL {
          ?person wdt:P31 wd:Q5 ; p:P39 ?held .
          ?held ps:P39 ?position ; pq:P580 ?start .
          FILTER NOT EXISTS { ?held pq:P582 ?end }
        }
      }  
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
    }
    # ${new Date().toISOString()}
    ORDER BY ?stateLabel ?start`
}
