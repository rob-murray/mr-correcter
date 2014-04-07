
module MrCorrecter
    class Correction
        attr_reader :incorrect_spelling, :correct_spelling

        def initialize(incorrect_spelling, correct_spelling)
            raise raise ArgumentError, "Invalid Argument" unless valid_corrections?(incorrect_spelling, correct_spelling)

            @incorrect_spelling = incorrect_spelling
            @correct_spelling = correct_spelling
        end

        def to_s
            "incorrect_spelling: #{@incorrect_spelling}-correct_spelling: #{@correct_spelling}"
        end

        private

        def valid_corrections?(incorrect_spelling, correct_spelling)

            if incorrect_spelling.nil? || correct_spelling.nil?
                return false
            end

            if incorrect_spelling.empty? || correct_spelling.empty?
                return false
            end

            if incorrect_spelling == correct_spelling
                return false
            end

            return true
        end

    end
end