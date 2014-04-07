require "spec_helper"

describe MrCorrecter::Correction do

    describe "creating" do

        it "should raise exception if incorrect spelling is nil" do
            expect { MrCorrecter::Correction.new(nil, "test") }.to raise_error(ArgumentError)
        end

        it "should raise exception if incorrect spelling is empty" do
            expect { MrCorrecter::Correction.new("", "test") }.to raise_error(ArgumentError)
        end

        it "should raise exception if correct spelling is nil" do
            expect { MrCorrecter::Correction.new("test", nil) }.to raise_error(ArgumentError)
        end

        it "should raise exception if correct spelling is empty" do
            expect { MrCorrecter::Correction.new("test", "") }.to raise_error(ArgumentError)
        end

        it "should raise exception if both arguments are equal" do
            expect { MrCorrecter::Correction.new("test", "test") }.to raise_error(ArgumentError)
        end

        it "should create instance with valid args" do
            correcter = MrCorrecter::Correction.new("tset", "test")
            expect(correcter).not_to be_nil
        end

    end

    describe "#attributes" do

        subject(:correction) { MrCorrecter::Correction.new("tset", "test") }

        it "should have accessible incorrect_spelling attribute" do
            expect(correction.incorrect_spelling).to eq("tset")
        end

        it "should have accessible incorrect_spelling attribute" do
            expect(correction.correct_spelling).to eq("test")
        end

    end

end