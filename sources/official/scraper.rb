#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      alt.empty? ? src : alt
    end

    def position
      noko.parent.parent.css('a/@href').text.split('/').last
    end

    private

    def alt
      noko.attr('alt').tidy
    end

    def src
      noko.attr('src').split('/').last
    end

  end

  class Members
    def member_container
      noko.css('.tile img.image-inline')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
