require_relative "spec_helper"
require 'vcr'
require 'webmock'

describe DataAnalytics do

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
    c.hook_into :webmock
  end

  let(:data_analytics) {DataAnalytics.new }
  subject { data_analytics }

  context "initial conditions" do
    its(:keywords_count) { should be_a_kind_of Hash }
    its(:images) {should be_a_kind_of Array}
  end

  context "extractKeywordsFunction" do

    context 'with a tweet about Apple' do

      specify ('The keyword should be Steve Jobs') do

        VCR.use_cassette("keywordExtraction") do
          subject.extractKeywords "I love Apple and Steve Jobs"
          subject.keywords_count["Steve Jobs"].should equal 1
        end
      end

    end

  end

  context "extractHashTagsFunction" do

    context "with a single hash tag" do
      specify "hashtag should be apple" do
        subject.extractKeywords "Just got a new iPhone #apple"
        subject.keywords_count["#apple"].should equal 1
      end
    end

    context "with multiple hashtags" do
      specify "hashtags should be apple and iPhone" do
        subject.extractKeywords "Just got a new iPhone #apple #iphone"
        subject.keywords_count["#apple"].should equal 1
        subject.keywords_count["#iphone"].should equal 1
      end
    end

    context "with multiple hashtags mixed in the text" do
      specify "hashtags should be apple and iPhone" do
        subject.extractKeywords "Just got a new #phone its an #apple #iPhone"
        subject.keywords_count["#apple"].should equal 1
        subject.keywords_count["#iPhone"].should equal 1
        subject.keywords_count["#phone"].should equal 1
      end
    end

  end

  context "extractImagesFunction" do

    context "with images from Twitter" do

      context "with a single image" do
        specify("image url should be pic.twitter.com/abcf") do
          subject.extractImages "pic.twitter.com/abcf"
          subject.images.include? "pic.twitter.com/abcf".should be_true
        end
      end

    end
  end

end
