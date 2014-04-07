
module MrCorrecter
    class Configuration
        attr_accessor :logger_output, :search_period_hours, :post_tweets,
            :twitter_consumer_key, :twitter_consumer_secret, :twitter_oauth_token, :twitter_oauth_secret

        def initialize
            @logger_output = STDOUT
            @post_tweets = false
            @search_period_hours = 1
        end
    end
end