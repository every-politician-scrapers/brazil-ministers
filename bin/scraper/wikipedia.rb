#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class MinistersList < Scraped::HTML
  decorator RemoveReferences
  decorator WikidataIdsDecorator::Links

  field :ministers do
    member_entries.map { |ul| fragment(ul => Officeholder).to_h }
  end

  private

  def member_entries
    table.flat_map { |table| table.xpath('.//tr[td[contains(., "Incumbent")]]') }
  end

  def table
    noko.xpath('//h2[contains(.,"Cabinet")]/following::table[.//th[contains(.,"Incumbent")]]')
  end
end

class Officeholder < Scraped::HTML
  field :wdid do
    name_link.attr('wikidata')
  end

  field :name do
    name_link.text.tidy
  end

  field :position do
    noko.xpath('preceding::h3[1]').css('.mw-headline').text.tidy
  end

  field :start do
    tds[4].text.tidy
  end

  private

  def tds
    noko.css('td')
  end

  def name_link
    noko.xpath('.//td[3]//a')
  end
end

url = 'https://en.wikipedia.org/wiki/Bolsonaro_administration_cabinet_members'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).ministers

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
