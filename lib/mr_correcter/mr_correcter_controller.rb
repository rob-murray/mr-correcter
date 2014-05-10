
module MrCorrecter
  class MrCorrecterController
    def initialize(twitter_adapter, logger, search_period = MrCorrecter.configuration.search_period_hours)
      @twitter_adapter = twitter_adapter
      @logger = logger
      @search_period = search_period
      @new_tweet_post_interval = MrCorrecter.configuration.new_tweet_post_interval
    end

    def find_and_correct(corrections = [])
      corrections.each do |correction|
        @logger.info("Searching for Correction: #{correction}")

        @results = find(correction.incorrect_spelling)
        @logger.info("Found #{@results.size} tweets")

        correct_all(@results, correction)
      end
    end

    private

    def correct_all(tweets_with_spelling_errors, correction)
      tweets_with_spelling_errors.each_with_index do |tweet, i|
        correct(tweet, correction)

        if (i + 1) % @new_tweet_post_interval == 0
          @logger.info('Posting a spelling update')

          spelling_update_tweet = CorrectionTweet.new(correction)
          post(spelling_update_tweet.text)
        end
      end
    end

    def correct(tweet, correction)
      reply_tweet_text = AnnoyingCorrectionTweet.new(correction).text

      @logger.debug("Replying to #{tweet.id} with '#{reply_tweet_text}'")

      begin
        @twitter_adapter.reply_to(tweet, reply_tweet_text) if MrCorrecter.configuration.post_tweets
      rescue => e
        @logger.warn("Exception! #{e.message}")
      end
    end

    def post(text)
      @logger.debug("Posting '#{text}'")

      begin
        @twitter_adapter.send(text) if MrCorrecter.configuration.post_tweets
      rescue => e
        @logger.warn("Exception! #{e.message}")
      end
    end

    def find(text)
      results = []
      @logger.info("Finding text: #{text}")

      begin
        results = @twitter_adapter.search(text, @search_period * 60)
      rescue => e
        @logger.warn("Exception! #{e.message}")
      end

      results
    end
  end
end
