#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    noko.css('span').remove
    'Portrait'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[no img name age dates].freeze
    end

    def empty?
      (tds[0].text.to_i <= 0) || super
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
