#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Foto'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[number name img ministry start end].freeze
    end

    def raw_end
      super.downcase.gsub(' de de ', ' de ')
    end

    def empty?
      (itemLabel == 'vago') || too_early?
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
