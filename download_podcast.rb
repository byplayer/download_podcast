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
  enclosure = (item / 'enclosure')
  url = enclosure.attr('url')
  file_size = enclosure.attr('length').value.to_i
  org_file_name = File.basename(url, '*.*')
  unless org_file_name =~ /^(suzuki_vol)([0-9]+)(.*)/
    puts 'file name format error'
    break
  end

  # normalize 3 degit
  file_name =
    format('%s%03d%s',
           Regexp.last_match[1],
           Regexp.last_match[2].to_i,
           Regexp.last_match[3])

  org_file_path = File.join(DEST_DIR, org_file_name)

  print "download: #{file_name} "
  file_path = File.join(DEST_DIR, file_name)

  if org_file_path != file_path && File.exist?(org_file_path)
    FileUtils.mv(org_file_path, file_path)
  end

  if File.exist?(file_path)
    puts 'skip due to already exist'
  else
    puts
    agent.download(url, file_path)
  end

  # verify size
  # comment out this logic
  # because some file isn't set correct mp3 file size.
  # actual_size = File::Stat.new(file_path).size
  # next unless actual_size != file_size

  # puts "error: wrong file size(#{file_path})"
  # puts "  expected: #{file_size}"
  # puts "  actual  : #{actual_size}"
end
