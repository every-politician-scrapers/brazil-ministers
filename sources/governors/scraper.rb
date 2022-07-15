#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require_relative './../../lib/unspan_all_tables'

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
  decorator UnspanAllTables

  field :ministers do
    member_entries.map { |ul| fragment(ul => Officeholder).to_h }.uniq
  end

  private

  def member_entries
    noko.xpath('.//table[.//th[contains(.,"Mandato")]][1]//tr[td[.//img]]')
  end
end

class Officeholder < Scraped::HTML
  field :state do
    state_link.attr('wikidata')
  end

  field :stateLabel do
    state_link.text.tidy
  end

  field :person do
    name_link.attr('wikidata')
  end

  field :personLabel do
    name_link.text.tidy
  end

  private

  def tds
    noko.css('td')
  end

  def state_link
    noko.xpath('.//th[1]//a[not(img)]').first
  end

  def name_link
    tds[1].xpath('.//a[@href]').first
  end
end

url = 'https://pt.wikipedia.org/wiki/Lista_de_governadores_das_unidades_federativas_do_Brasil'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).ministers

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
