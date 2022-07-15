#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Members
    decorator RemoveReferences
    decorator UnspanAllTables
    decorator WikidataIdsDecorator::Links

    def member_container
      member_table.flat_map { |table| table.xpath('.//tr[td[contains(., "Incumbent")]]') }
    end

    def member_table
      noko.xpath('//h2[contains(.,"Cabinet")]/following::table[.//th[contains(.,"Incumbent")]]')
    end
  end

  class Member
    field :id do
      name_node.css('a/@wikidata').first
    end

    field :name do
      name_node.text.tidy
    end

    field :positionID do
    end

    field :position do
      noko.xpath('preceding::h3[1]').css('.mw-headline').text.tidy
    end

    field :startDate do
      Date.parse(tds[4].text.tidy).to_s
    end

    field :endDate do
    end

    private

    def tds
      noko.css('td')
    end

    def name_node
      tds[2]
    end

    def raw_start
      tds[2].text.split('-').first
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url).csv
