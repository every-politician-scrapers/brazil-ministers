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
      %w[ordinal _ name image _ start end].freeze
    end

    def empty?
      itemLabel.to_s.empty? || (tds[0].text == tds[1].text)
    end

    def raw_start
      super.gsub('1.º', '1').tidy
    end

    def raw_end
      super.gsub('1.º', '1').gsub('Em exercício', '').tidy
    end

    def tds
      noko.css('td,th')
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
