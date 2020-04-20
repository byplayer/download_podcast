# frozen_string_literal: true

require 'bundler/setup'
require 'fileutils'
require 'mechanize'

DEST_DIR = File.join(__dir__, 'download')
TARGET_URL = 'https://www.tfm.co.jp/podcasts/asemamire/podcast.xml'

FileUtils.mkdir_p(DEST_DIR)

agent = Mechanize.new

response = agent.get(TARGET_URL)

doc = Nokogiri::XML.parse(response.body)
(doc / '/rss/channel/item').each do |item|
  url = (item / 'guid').inner_text
  file_name = File.basename(url, '*.*')
  puts "download: #{file_name}"
  file_path = File.join(DEST_DIR, file_name)
  if File.exist?(file_path)
    puts 'skip due to already exist'
    next
  end

  agent.download(url, file_path)
end
