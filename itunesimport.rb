#!/usr/bin/ruby

# Bundler
require 'rubygems'
require 'bundler/setup'

# Dependencies
require 'open-uri'
require 'nokogiri'
require 'httpclient'
require 'ruby-progressbar'
require 'fileutils'

# Validate input URI
if not ARGV[0] =~ /^#{URI::regexp}$/ then
  abort "Invalid URI."
end

# Build base URI from input
base_uri = URI(ARGV[0])

# Parse the document at the URI
begin
  doc = Nokogiri::HTML(open(base_uri))
  puts 'Importing "' + URI.unescape(base_uri.to_s) + '"...'
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
FileUtils.rm_rf('temp')
FileUtils.mkdir('temp')

# Counter used to inform user of current item
i = 0

# Iterates over URIs for the `href` attribute in our nodelist
for item_uri in nodes.collect{|n| URI.join(base_uri, n['href'])}
  # Open file for writing
  f = File.open('temp/' + nodes[i]['href'], 'w')
  
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
    :title  => URI.unescape(nodes[i]['href']),
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
`open -a iTunes #{nodes.collect{|n| 'temp/' + n['href']}.join(' ')}`