require 'alchemy_api'
require 'parseconfig'

class DataAnalytics

  attr_accessor :keywords_count, :images

  def initialize
    #A new hash to store the keywords in
    @keywords_count = Hash.new(0)
    # An array to store the URL of any images
    @images = Array.new

    # Set up alchemy
    configuration = ParseConfig.new( '/home/aaronkalair/Desktop/Dropbox/University/Year 3/CS310 Project/jacob/lib/jacob/configuration' )

    AlchemyAPI.configure do |config|
      config.apikey = configuration["alchemy_key"]
    end

  end

  #Extracts the keywords from a given tweet and adds them to the hash
  def extractKeywords tweet
    results = AlchemyAPI.search(:keyword_extraction, :text => tweet)
      unless results.nil?
        results.each do |keyword|
          @keywords_count[keyword['text']] = @keywords_count[keyword['text']] + 1
        end
      else
      end
  end

  #Extracts any hashtags from tweets
  def extractHashTags tweet
    tweet.scan(/#\w+/).each do |hashtag|
      @keywords_count[hashtag] = @keywords_count[hashtag]
    end
  end

  #Extracts any image urls from tweets
  def  extractImages tweet
    tweet.scan(/pic.twitter.com\/\w+/).each do |image|
      @images << image
    end
  end


end
