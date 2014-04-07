require 'rspec/core'
require 'rspec/core/rake_task'
 
task :default => :spec

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec)


desc "Run MrCorrecter"
task :run do |t, args|
    require_relative 'lib/mr_correcter'

    MrCorrecter.configure do |config|
      config.post_tweets = false
      config.search_period_hours = 2

      config.twitter_consumer_key = 'secret'
      config.twitter_consumer_secret = 'secret'
      config.twitter_oauth_token = 'secret'
      config.twitter_oauth_secret = 'secret'
    end

    # examples
    MrCorrecter.add_correction("accomodate", "accommodate")
    MrCorrecter.add_correction("beleive", "believe")
    MrCorrecter.add_correction("curiousity", "curiosity")

    MrCorrecter.correct!
    # end
end