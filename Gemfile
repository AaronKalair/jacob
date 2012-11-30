source 'https://rubygems.org'

group :development do
  gem 'rb-inotify'  # Monitors the filesystem for changes
  gem 'libnotify'   # Provides pretty notices when something happens
  gem 'guard-bundler' # So guard can auto download and install new gems when I add them
  gem 'rb-fsevent'  # Monitor the file system on OS X
  gem 'growl' # Notifications on OS
  gem 'geokit' # For working with coordinates
  gem 'twitter' # For working with the twitter REST API
  gem 'tweetstream' # For working with the twitter streaming API
  gem 'alchemy-api-rb', :require => 'alchemy_api' # For working with the alchemy API
  gem 'parseconfig' # For parsing configuration files
end

group :test do
  gem 'rake'  # Allows me to use a rakefile (simmilar to a make file in C)
  gem 'rspec' # The rspec testing suite
  gem 'guard-rspec'  # Automatically run the test suite when a file is modified
  gem 'vcr' # For testing API calls
  gem 'webmock' # For testing API calls
end
