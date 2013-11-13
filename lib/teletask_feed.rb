require 'time'
require 'net/http'

require 'xmlsimple'
require 'chronic_duration'

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

   raise "ERROR: Can't parse tracks out of feed. Does it have .mp4 assets? Is it the right Teletask feed series URL?" unless @input_xml["channel"].first["item"]

    @input_xml["channel"].first["item"].each do |d|
      title = Time.parse(d["pubDate"].first).strftime("%Y-%m-%d")
      title += " "
      title += d["title"].first

      @tracks.push({
        "title" => [title],
        "location" => [d["link"].first],
        "duration" => [duration(d["duration"].first)]
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

    @tracks.each do |track|
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

    @input_xml = XmlSimple.xml_in(get_with_redirects(uri, 3))

    puts "Fetching feed. Finished"
  end

  def get_with_redirects(uri, limit)
    # copied from http://ruby-doc.org/stdlib-2.0.0/libdoc/net/http/rdoc/Net/HTTP.html#label-Following+Redirection

    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    response = Net::HTTP.get_response(uri)

    case response
    when Net::HTTPSuccess then
      response.body
    when Net::HTTPRedirection then
      location = response['location']
      warn "redirected to #{location}"
      get_with_redirects(URI(location), limit - 1)
    else
      response.value
    end
  end

  # Converts duration strings like 00:09:26 to milliseconds
  def duration(duration_string)
    ChronicDuration.parse(duration_string) * 1000
  end
end
