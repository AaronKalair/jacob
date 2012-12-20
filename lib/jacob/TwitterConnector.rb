require 'geokit'
require 'twitter'
require 'tweetstream'
require_relative('../../MyConfig')

class TwitterConnector

  attr_accessor :lat, :lng, :radius, :bounding_box

  def initialize lat, lng, radius
    @lat, @lng, @radius = lat, lng, radius

    @extractor = DataAnalytics.new
    generateBoundingBox

    # Configure the authentication data for the Twitter REST API
    Twitter.configure do |config|
      config.consumer_key       = MyConfig::TWITTER_CONSUMER_KEY
      config.consumer_secret    = MyConfig::TWITTER_CONSUMER_SECRET
      config.oauth_token        = MyConfig::TWITTER_OAUTH_TOKEN
      config.oauth_token_secret = MyConfig::TWITTER_OAUTH_TOKEN_SECRET
    end

    # Configure the authentication for the Twitter streaming API
    TweetStream.configure do |config|
      config.consumer_key       = MyConfig::TWITTER_CONSUMER_KEY
      config.consumer_secret    = MyConfig::TWITTER_CONSUMER_SECRET
      config.oauth_token        = MyConfig::TWITTER_OAUTH_TOKEN
      config.oauth_token_secret = MyConfig::TWITTER_OAUTH_TOKEN_SECRET
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

      # We can get images hosted by twitter here:
      status.media.each do |image|
        # Add the image to our collection of images
        @extractor.images << image.media_url
        status.text.gsub!(image.display_url, "")
      end

      @extractor.printKeywords
      puts "\n"
      @extractor.printImages
      puts "\n"

      # Process this status
      handleTweet status

    end

  end

  # The main method which starts trending topic discovery
  def getTrends
    # Get the keywords from the last 100 tweets in the area
    getAllTweetsUntilX.each do |status|
      puts "processing " + status.text
      handleTweet status
    end
    # Process the incoming keywords
    bounding = generateBoundingBox
    getIncomingTweets bounding
  end

  # Checks if a given status is within the bounding box (because Twitter sometimes returns tweets that are not) and then sends it off to have the data extracted
  def handleTweet status
    # If we have geo data we can check ourselves that its within the bounding box
    unless status.geo.nil?
        if validLocation? status.geo.coords[0], status.geo.coords[1]
          @extractor.processTweet status.text
        end
    # If we don't have any geo data attached to the tweet we'll have to take Twitters word that its within the bounding box
    else
      @extractor.processTweet status.text
    end
  end

end
