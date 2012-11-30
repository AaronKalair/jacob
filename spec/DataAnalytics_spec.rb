require_relative "spec_helper"
require 'vcr'
require 'webmock'
require 'alchemy_api'

describe DataAnalytics do

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
    c.hook_into :webmock
  end

  let(:data_analytics) {DataAnalytics.new }
  subject { data_analytics }

  context "initial conditions" do
    its(:keywords_count) { should be_a_kind_of Hash }
  end

  context "extractKeywordsFunction" do

    lambda{ subject.extractKeywords "I love Apple and Steve Jobs" }

    context 'with a tweet about Apple' do
      specify ('The keyword should be Steve Jobs') do
        VCR.use_cassette("keywordExtraction") do
          data_analytics.keywords_count["Steve Jobs"].should equal 1
        end
      end

    end

  end

  context "extractHashTagsFunction" do
  end

  context "extractImagesFunction" do
  end

end
