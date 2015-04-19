require 'logger'

require_relative 'mr_correcter/annoying_correction_tweet'
require_relative 'mr_correcter/configuration'
require_relative 'mr_correcter/correction'
require_relative 'mr_correcter/correction_tweet'
require_relative 'mr_correcter/mr_correcter_controller'
require_relative 'mr_correcter/twitter_adapter'

module MrCorrecter
  @corrections = []

  class << self
      attr_accessor :configuration, :corrections

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def load_config(filename)
      @configuration = Configuration.load_from_file(filename)
    end

    def logger
      @logger ||= Logger.new(configuration.logger_output)
    end

    def add_correction(incorrect_spelling, correct_spelling)
      @corrections << Correction.new(incorrect_spelling, correct_spelling)
      logger.info("Created Correction: #{incorrect_spelling}, #{correct_spelling}")
    end

    def correct!
      logger.info "Starting MrCorrecter! Searching for text within search period of #{configuration.search_period_hours} hours"
      logger.warn format('Tweet posting is: %s', (configuration.post_tweets ? 'ENABLED' : 'DISABLED'))

      controller = MrCorrecterController.new(TwitterAdapter.new(auth), logger)
      controller.find_and_correct(@corrections)

      logger.info 'Finished.'
    end

    def auth
      { consumer_key: configuration.twitter_consumer_key, consumer_secret: configuration.twitter_consumer_secret,
        oauth_token: configuration.twitter_oauth_token, oauth_secret: configuration.twitter_oauth_secret }
    end
  end
end
