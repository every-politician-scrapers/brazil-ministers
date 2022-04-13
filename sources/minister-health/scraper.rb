#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Início'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[number name start end].freeze
    end

    #TODO: push up
    def raw_end
      super.gsub('–', '')
    end

    def empty?
      super || itemLabel.include?('vago')
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
