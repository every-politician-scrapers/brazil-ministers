#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Imagem'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[ordinal name image party start end].freeze
    end

    def raw_end
      super.gsub('Em exercício', '').tidy
    end

    def empty?
      (tds[3].text == tds[4].text) || (startDate < '1985-01-01') || too_early?
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
