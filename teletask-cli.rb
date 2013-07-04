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

  def get_feed
    uri = URI(@location)
    raise "Location must be valid uri, but is #{@location}" unless uri

    @input_xml = XmlSimple.xml_in(Net::HTTP.get(uri))
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
    raise "call parse_tracks before writing xspf" if @tracks.empty?

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
    puts "Written xspf to #{@output_path}"
  end

  self
end

options = {}
options_parser =
  OptionParser.new do |opts|
    opts.banner = "Usage: teletask-cli.rb [options]"

    opts.on("-f", "--feed LOCATION", "Location url of the feed to get") do |location|
      options[:location] = location
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end
options_parser.parse!

if(options[:location])
  TeletaskFeed
    .new(options[:location])
    .parse_tracks
    .write_xspf
else
  puts options_parser
end

