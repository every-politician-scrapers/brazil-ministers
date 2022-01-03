#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

require 'open-uri/cached'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  # in <td> not <th>
  def holder_entries
    noko.xpath('//table[.//tr[contains(.,"Imagem")]][last()]//tr[td]').drop(1)
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[ordinal name image party start end notes].freeze
    end

    def empty?
      (tds[0].text.tidy == 'Nº') || (tds.first.text == tds.last.text) || itemLabel.to_s.empty?
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
