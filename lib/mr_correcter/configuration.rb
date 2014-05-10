require 'yaml'

module MrCorrecter
  class Configuration
    attr_accessor :logger_output, :search_period_hours, :post_tweets, :new_tweet_post_interval,
                  :twitter_consumer_key, :twitter_consumer_secret, :twitter_oauth_token, :twitter_oauth_secret

    def initialize
      @logger_output = STDOUT
      @post_tweets = false
      @search_period_hours = 1
      @new_tweet_post_interval = 50
    end

    def self.load_from_file(filename)
      external_config = YAML.load_file(filename)

      config = Configuration.new
      config.search_period_hours = external_config['mr_correcter']['search_period_hours']
      config.post_tweets = external_config['mr_correcter']['post_tweets']
      config.new_tweet_post_interval = external_config['mr_correcter']['new_tweet_post_interval']
      config.twitter_consumer_key = external_config['twitter']['consumer_key']
      config.twitter_consumer_secret = external_config['twitter']['consumer_secret']
      config.twitter_oauth_token = external_config['twitter']['oauth_token']
      config.twitter_oauth_secret = external_config['twitter']['oauth_secret']

      config
    end
  end
end
