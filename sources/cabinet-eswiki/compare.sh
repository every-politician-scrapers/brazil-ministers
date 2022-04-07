#!/bin/bash

cd $(dirname $0)

# eswiki lists the members, but only with announcement dates and start dates
# so we wantt to get the full list, but then only take the last of each for comparison
bundle exec ruby scraper.rb $(jq -r .source meta.json) > scraped-full.csv
qsv dedup -s ministryLabel scraped-full.csv > scraped-current.csv
wd sparql -f csv wikidata.js | sed -e 's/T00:00:00Z//g' -e 's#http://www.wikidata.org/entity/##g' | qsv dedup -s psid > wikidata.csv
bundle exec ruby diff.rb | tee diff.csv

cd ~-
