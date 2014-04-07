require "spec_helper"

describe MrCorrecter::MrCorrecterController do

    let(:logger) { stub_everything }

    let(:adapter) { mock() }

    let(:correction_1) { MrCorrecter::Correction.new("tset", "test") }
    let(:correction_2) { MrCorrecter::Correction.new("wrod", "word") }
    let(:corrections) { [correction_1, correction_2] }

    let(:result_1) { Twitter::Tweet.new({
                    :id => "tweet1",
                    :created_at => Time.now.to_s
                }) }
    let(:result_2) { Twitter::Tweet.new({
                    :id => "tweet2",
                    :created_at => Time.now.to_s
                }) }
    let(:results) { [result_1, result_2] } 

    let(:search_period) { 10 }

    subject(:controller) { MrCorrecter::MrCorrecterController.new(adapter, logger, search_period) }

    describe "#find_and_correct" do

        before(:each) do
            adapter.stubs(:search).returns(results)
        end

        it "should find all tweets with incorrect text" do
            adapter.expects(:search).with(correction_1.incorrect_spelling, search_period*60).returns([])
            controller.find_and_correct([correction_1])
        end

        context "when post_tweets is enabled" do

            before do
                MrCorrecter.configure do |config|
                    config.post_tweets = true
                end
            end

            it "should reply to each tweet with a correcting tweet" do
                adapter.expects(:reply_to).with(result_1, anything)
                adapter.expects(:reply_to).with(result_2, anything)
                controller.find_and_correct([correction_1])
            end

        end

        context "when post_tweets is disabled" do

            before do
                MrCorrecter.configure do |config|
                    config.post_tweets = false
                end
            end

            it "should reply to each tweet with a correcting tweet" do
                adapter.expects(:reply_to).never
                controller.find_and_correct([correction_1])
            end

        end

        context "when Twitter API malfunctions" do

            before do
                MrCorrecter.configure do |config|
                    config.post_tweets = true
                end
            end

            it "should catch search exception and continue" do
                adapter.stubs(:search).with(any_parameters).raises(Exception)
                adapter.expects(:reply_to).never

                controller.find_and_correct([correction_1])
            end

            it "should catch reply exception and continue to next reply" do
                adapter.stubs(:search).returns(results)

                adapter.stubs(:reply_to).with(result_1, anything).raises(Exception)
                adapter.expects(:reply_to).with(result_2, anything)

                controller.find_and_correct([correction_1])
            end

        end

    end

    describe "posting tweets in between posting replies" do

        it "should post a tweet at a regular interval"

    end

end