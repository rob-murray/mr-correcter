
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
    end
end