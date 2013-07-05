require 'xmlsimple'

require 'time'
require 'net/http'
require 'optparse'

class TeletaskFeed
  def initialize(location)
    @location = location
    @input_xml = nil
    @output_path = "output.xspf"

    @tracks = []

    get_feed
  end

  def parse_tracks
    @tracks = []

   raise "Can't parse XML. Right teletask feed series URL?" unless @input_xml["channel"].first["item"]

    @input_xml["channel"].first["item"].each do |d|
      title = Time.parse(d["pubDate"].first).strftime("%Y-%m-%d")
      title += " "
      title += d["title"].first

      @tracks.push({
        "title" => [title],
        "location" => [d["link"].first]
      })
    end

    self
  end

  def write_xspf
    raise "Error: call parse_tracks before writing xspf" if @tracks.empty?

    puts "Writing xspf to #{@output_path}. Started ..."

    output = {
      "playlist" => {
        "version" => "1",
        "xmlns" => "http://xspf.org/ns/0/",
        "trackList" => [
          {
            "track" => @tracks
          }
        ]
      }
    }

    File.open(@output_path, "w") do |file|
      file.write(XmlSimple.xml_out(output, "keeproot" => true))
    end

    puts "Writing xspf to #{@output_path}. Finished"

    self
  end

  def download_files
    puts "Downloading files. Started ..."

    @tracks.slice(10,1).each do |track|
      `wget #{track["location"].first}`
    end

    puts "Downloading files. Finished"

    self
  end

  private

  def get_feed
    puts "Fetching feed. Started ..."

    uri = URI(@location)
    raise "Location must be valid uri, but is #{@location}" unless uri

    @input_xml = XmlSimple.xml_in(Net::HTTP.get(uri))

    puts "Fetching feed. Finished"
  end
end

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

