
module MrCorrecter
    class CorrectionTweet

        BASE_TEXT_LIST = [
            "This is the correct spelling for '%s'",
            "This is how you spell '%s'",
            "Many people spell '%s' incorrectly",
            "A common word misspelled is '%s'"
        ]

        def initialize(correction)
            raise raise ArgumentError, "Invalid Argument: correction nil" if correction.nil?
            
            @correction = correction
        end

        def text
            BASE_TEXT_LIST.sample % @correction.correct_spelling
        end

    end
end