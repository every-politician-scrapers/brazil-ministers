#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'mandato'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[ordinal name image dates].freeze
    end

    def raw_combo_date
      super.gsub('até', ' – ').gsub(/\(.*?\)/, '')
    end

    def empty?
      (tds[3].text == tds[4].text) || too_early?
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
