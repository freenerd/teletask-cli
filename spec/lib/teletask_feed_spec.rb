require_relative '../../lib/teletask_feed'

require 'rspec'

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = './spec/fixtures/vcr/'
  c.hook_into :webmock
end

TEST_URL_DEPENDABLE_SYSTEMS = "http://tele-task.de/feeds/series/946/"
TEST_URL_DATA_PROFILING = "http://tele-task.de/feeds/series/948/"

describe TeletaskFeed do
  it "initializes" do
    VCR.use_cassette('dependable_systems') do
      TeletaskFeed.new(TEST_URL_DEPENDABLE_SYSTEMS)
    end
  end

  it "parses tracks" do
    VCR.use_cassette('dependable_systems') do
      object = TeletaskFeed.new(TEST_URL_DEPENDABLE_SYSTEMS)

      object.parse_tracks
      tracks = object.instance_variable_get("@tracks")

      #tracks.should be_of_type(Array)
      tracks.length.should == 126
      tracks.first["title"].should == [ "2013-04-09 Definitions and Metrics #1/6: Dependability" ]
      tracks.first["location"].should == [ "http://stream.hpi.uni-potsdam.de:8080/download/podcast/SS_2013/DPS_SS13/DPS_2013_04_09/DPS_2013_04_09_part_1_podcast.mp4" ]
      tracks.first["duration"].should == [ 759000 ]
    end
  end

  it "throws exception if no tracks" do
    VCR.use_cassette('data_profiling') do
      expect do
        TeletaskFeed.new(TEST_URL_DATA_PROFILING).parse_tracks
      end.to raise_error(Exception)
    end
  end
end
