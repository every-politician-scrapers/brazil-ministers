#!/bin/bash

cd $(dirname $0)

# eswiki lists the members, but only with announcement dates and start dates
# so we want to get the full list, but then only take the last of each for comparison
bundle exec ruby scraper.rb $(jq -r .reference.P4656 meta.json) > scraped-full.csv
qsv dedup -s position scraped-full.csv |
  qsv select id,name,positionID,position,startDate,endDate |
  qsv rename item,itemLabel,position,positionLabel,startDate,endDate > scraped.csv
wd sparql -f csv wikidata.js | sed -e 's/T00:00:00Z//g' -e 's#http://www.wikidata.org/entity/##g' | qsv dedup -s psid > wikidata.csv
bundle exec ruby diff.rb | qsv sort -s itemlabel | tee diff.csv

cd ~-
