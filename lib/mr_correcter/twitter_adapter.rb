require 'twitter'

module MrCorrecter
  class TwitterAdapter
    def initialize(auth)
      fail ArgumentError, 'No auth is specified' if auth.nil?

      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = auth[:consumer_key]
        config.consumer_secret     = auth[:consumer_secret]
        config.access_token        = auth[:oauth_token]
        config.access_token_secret = auth[:oauth_secret]
      end
    end

      # Search Twitter for `text`. Add optional time param to restrict search
      #
      # @param text [String] Search for
      # @param since_mins_ago [Int] Results must be within X mins of now. Defaults to off.
      # @return [Twitter::SearchResults]
    def search(text, since_mins_ago = 0)
      tweets = []
      return tweets if text.nil? || text.empty?

      # rate limited!
      @client.search("\"#{text}\"").each do |result|
        if since_mins_ago > 0
          tweets << result if tweet_in_time?(result.created_at, time_ago_in_seconds(since_mins_ago))
        else
          tweets << result
        end
      end

      tweets
    end

      # Send a tweet
      #
      # @param text [String] Message to post
      # @param options [Hash] Optional options. See Twitter Gem.
    def send(text, options = {})
      return if text.nil? || text.empty?

      @client.update(text, options) # rate limited!
    end

      # Reply to a particular tweet
      #
      # @param original_tweet [Twitter::Tweet] The Tweet object to reply to
      # @param text [String] The reply
    def reply_to(original_tweet, text)
      return if original_tweet.nil?

      reply_to_text = "@#{original_tweet.user.screen_name} #{text}" # Looks like you have to include the username too
      send(reply_to_text, in_reply_to_status: original_tweet)
    end

    private

    def tweet_in_time?(tweet_created_at, valid_start_time)
      tweet_created_at.between?(valid_start_time, Time.now)
    end

    def get_time_ago(time_ago_seconds)
      Time.now - time_ago_seconds
    end

    def time_ago_in_seconds(since_mins_ago)
      get_time_ago(since_mins_ago * 60)
    end
  end
end
