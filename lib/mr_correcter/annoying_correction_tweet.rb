require_relative 'correction_tweet'

module MrCorrecter
  class AnnoyingCorrectionTweet < CorrectionTweet
    BASE_TEXT = "I think you meant to type '%s'"

    def initialize(correction)
      super(correction)
    end

    def text
      BASE_TEXT % @correction.correct_spelling
    end
  end
end
