require 'geokit'
require 'twitter'
require 'tweetstream'

class TwitterConnector

  attr_accessor :lat, :lng, :radius, :bounding_box

  def initialize lat, lng, radius
    @lat, @lng, @radius = lat, lng, radius

    configuration = ParseConfig.new( '/home/aaronkalair/Desktop/Dropbox/University/Year 3/CS310 Project/jacob/lib/jacob/configuration' )

    # Configure the authentication data for the Twitter REST API
    Twitter.configure do |config|
      config.consumer_key       = configuration["twitter_consumer_key"]
      config.consumer_secret    = configuration["twitter_consumer_secret"]
      config.oauth_token        = configuration["twitter_oauth_token"]
      config.oauth_token_secret = configuration["twitter_oauth_token_secret"]
    end

    # Configure the authentication for the Twitter streaming API
    TweetStream.configure do |config|
      config.consumer_key       = configuration["twitter_consumer_key"]
      config.consumer_secret    = configuration["twitter_consumer_secret"]
      config.oauth_token        = configuration["twitter_oauth_token"]
      config.oauth_token_secret = configuration["twitter_oauth_token_secret"]
      config.auth_method        = :oauth
    end

  end

  # Generates a bounding box that covers the area specified by the point and a radius
  def generateBoundingBox lat=@lat, lng=@lng, radius=@radius
    # Check we got valid input
    raise "invalid co ordinates or radius" unless radius >=0 && lat.between?(-90, 90) && lng.between?(-180,180)

    # Turn the co ordinates into a point object
    point = Geokit::LatLng.new lat, lng

    # Get the bounding box
    boundingBox = Geokit::Bounds.from_point_and_radius point, radius
    @bounding_box = boundingBox

    # Swap the lat and lng around as Twitter requires
    south_west_latitude, south_west_longitude, north_east_latitude, north_east_longitude = boundingBox.to_s.split(",")

    south_west_longitude << "," << south_west_latitude << "," << north_east_longitude << "," << north_east_latitude

  end

  # Returns if a point is within the bounding box
  def validLocation? lat, lng, bounding_box=@bounding_box
    # Create a new point from the coordinates
    point = Geokit::LatLng.new lat, lng
    # Return if this point is within the bounding box
    @bounding_box.contains? point
  end

  # Returns the latest X tweets from the location specified
  def getAllTweetsUntilX lat=@lat, lng=@lng, radius=@radius, limit=100
    results = Twitter.search "", {:geocode=> lat.to_s << "," << lng.to_s << "," << radius.to_s << "km", :lang=> "en", :count => limit, :include_entities => true }
    results.statuses
  end

  # Connect to the streaming API and pull in live tweets
  def getIncomingTweets bounding_box
    TweetStream::Client.new.on_error do |message|
      puts "Error: #{message.to_s} "
    end.locations(bounding_box) do |status|
      # Check the status is actually within our bounding box
      unless status.geo.nil?
        if validLocation? status.geo.coords[0], status.geo.coords[1]
          puts status.text
        end
      else
        puts status.text
      end
    end

  end

end
