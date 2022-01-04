#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

require 'open-uri/cached'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Retrato'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[ordinal color name image election start end party vice notes].freeze
    end

    def empty?
      itemLabel.to_s.empty? || (tds[0].text == tds[1].text)
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
