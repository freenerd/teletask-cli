#
# This script handles the command line input only
# The actual logic is in /lib
#

require_relative 'lib/teletask_feed.rb'
require 'optparse'

options = {}
options_parser =
  OptionParser.new do |opts|
    opts.banner = "Usage: teletask-cli.rb [options]"

    opts.on("-x", "--xspf LOCATION", "Generates an xspf playlist from a feed at location") do |location|
      options[:xspf] = location
    end

    opts.on("-d", "--download LOCATION", "Downloads all videos from a feed at location") do |location|
      options[:download] = location
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end
options_parser.parse!

if(options[:xspf])
  TeletaskFeed
    .new(options[:xspf])
    .parse_tracks
    .write_xspf
elsif(options[:download])
  TeletaskFeed
    .new(options[:download])
    .parse_tracks
    .download_files
else
  puts options_parser
end
