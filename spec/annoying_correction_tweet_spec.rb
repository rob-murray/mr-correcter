require "spec_helper"

describe MrCorrecter::AnnoyingCorrectionTweet do

    let(:correction){ MrCorrecter::Correction.new("tset", "test") }

    describe "creating" do

        it "should raise exception if correction argument nil" do
            expect { MrCorrecter::AnnoyingCorrectionTweet.new(nil) }.to raise_error(ArgumentError)
        end

        it "should create instance" do
            tweet = MrCorrecter::AnnoyingCorrectionTweet.new(correction)
            expect(tweet).not_to be_nil
        end

    end

    describe "generating tweet text" do

        subject(:tweet) { MrCorrecter::AnnoyingCorrectionTweet.new(correction) }

        it "should contain correct spelling of correction" do
            expect(tweet.text).to include(correction.correct_spelling)
        end

        it "should have additional text" do
            expect(tweet.text.length).to be > correction.correct_spelling.length
        end

    end

end