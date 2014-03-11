#!/usr/bin/env ruby

# Bundler
require 'rubygems'
require 'bundler/setup'

# Dependencies
require 'open-uri'
require 'nokogiri'
require 'httpclient'
require 'ruby-progressbar'
require 'fileutils'
require 'addressable/uri'
require 'tmpdir'

WORKING_DIR = "#{Dir.tmpdir}/itunesimport"

def friendly_filename(filename)
    filename = Addressable::URI.unescape filename
    filename.gsub(/[^.\w\s_-]+/, '')
            .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
            .gsub(/\s+/, '_')
end

SCHEMES = %w(http https)

def valid_url?(url)
  parsed = Addressable::URI.parse(url) or return false
  SCHEMES.include?(parsed.scheme)
rescue Addressable::URI::InvalidURIError
  false
end

# Validate input URI
if not valid_url?(ARGV[0]) then
  abort "Invalid URI (#{ARGV[0]})."
end

# Build base URI from input
base_uri = Addressable::URI.parse(ARGV[0])

# Parse the document at the URI
begin
  doc = Nokogiri::HTML(open(base_uri.normalize))
  puts 'Importing "' + Addressable::URI.unescape(base_uri.to_s) + '"...'
rescue Exception => e
  abort "Could not open URI (#{e.message})."
end

# HTTP client for downloading items
http = HTTPClient.new

# Find all `a` nodes, but filter out any that are not .mp3 links
nodes = doc.xpath('//a').reject{ |node| node['href'].length < 4 or node['href'][-4..-1].downcase != '.mp3' }

# Do not proceed if there are no items
if nodes.length == 0 then
  abort "No downloadable items in directory."
end

# Clear temp folder
FileUtils.rm_rf(WORKING_DIR)
FileUtils.mkdir(WORKING_DIR)

# Counter used to inform user of current item
i = 0

# Iterates over URIs for the `href` attribute in our nodelist
for item_uri in nodes.collect{|n| Addressable::URI.join(base_uri, n['href'])}
  # Open file for writing
  f = File.open("#{WORKING_DIR}/#{friendly_filename(nodes[i]['href'])}", 'w')
  
  # Get HTTP head request for information on file
  head = http.head(item_uri)
  
  # Do not proceed unless server responds correctly for file request
  if not head.status == 200 then
    abort "Invalid HTTP response (#{head.status})."
  end
  
  # The size (in bytes) of the file
  content_length = head.header['content-length'][0].to_i
  
  # Create a progress bar for the file
  bar = ProgressBar.create(
    :title  => Addressable::URI.unescape(nodes[i]['href']),
    # Displays: Item Number | Filesize | Name | Progress Bar | ETA
    :format => "#{i+1}/#{nodes.length}".rjust((nodes.length/10).ceil*2 + 4) + " | #{(content_length/1048576.0).round(1)}MB".ljust(9) + " | %t |%B| %p%% %E",
    :total  => content_length
  )  
  
  begin
    # Receive data in chunks so the progress bar can be updated
    resp = http.get_content(item_uri) {|chunk| 
      bar.progress += chunk.length
      f.write chunk
    }
  ensure
    # Make sure the file is closed and the progress bar is finished
    f.close
    bar.finish
    
    # Increment the item counter
    i += 1
  end
end


puts "Opening in iTunes..."

# Run the shell command to open files in iTunes
`open -a iTunes #{nodes.collect{|n| WORKING_DIR + '/' + friendly_filename(n['href'])}.join(' ')}`