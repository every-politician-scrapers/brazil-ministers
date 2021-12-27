#!/bin/bash

bundle exec ruby bin/scraper/governors-wikipedia.rb | ifne tee data/governors-wikipedia.csv
wd sparql -f csv bin/scraper/governors-wikidata.js | sed -e 's#http://www.wikidata.org/entity/##g' -e 's/T00:00:00Z//g' | qsv dedup -s psid | ifne tee data/governors-wikidata.csv
bundle exec ruby bin/diff-governors.rb | tee data/diff-governors.csv
