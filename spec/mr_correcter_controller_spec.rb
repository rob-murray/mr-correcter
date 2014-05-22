require 'spec_helper'

describe MrCorrecter::MrCorrecterController do

  let(:logger) { stub_everything }
  let(:adapter) { mock }
  let(:correction_1) { MrCorrecter::Correction.new('tset', 'test') }
  let(:correction_2) { MrCorrecter::Correction.new('wrod', 'word') }
  let(:corrections) { [correction_1, correction_2] }
  let(:result_1) do
    Twitter::Tweet.new(
      id: 'tweet1',
      created_at: Time.now.to_s)
  end
  let(:result_2) do
    Twitter::Tweet.new(
      id: 'tweet2',
      created_at: Time.now.to_s)
  end
  let(:result_3) do
    Twitter::Tweet.new(
      id: 'tweet3',
      created_at: Time.now.to_s)
  end
  let(:results) { [result_1, result_2, result_3] }
  let(:search_period) { 10 }

  describe '#find_and_correct' do
    subject(:controller) { MrCorrecter::MrCorrecterController.new(adapter, logger, search_period) }

    before(:each) { adapter.stubs(:search).returns(results) }

    it 'should find all tweets with incorrect text' do
      adapter.expects(:search).with(correction_1.incorrect_spelling, search_period * 60).returns([])

      controller.find_and_correct([correction_1])
    end

    context 'when post_tweets is enabled' do
      before do
        MrCorrecter.configure do |config|
          config.post_tweets = true
        end
      end

      after { MrCorrecter.reset }

      it 'should reply to each tweet with a correcting tweet' do
        adapter.expects(:reply_to).with(result_1, anything)
        adapter.expects(:reply_to).with(result_2, anything)
        adapter.expects(:reply_to).with(result_3, anything)

        controller.find_and_correct([correction_1])
      end
    end

    context 'when post_tweets is disabled' do
      before do
        MrCorrecter.configure do |config|
          config.post_tweets = false
        end
      end

      after { MrCorrecter.reset }

      it 'should reply to each tweet with a correcting tweet' do
        adapter.expects(:reply_to).never

        controller.find_and_correct([correction_1])
      end
    end

    context 'when Twitter API malfunctions' do
      before do
        MrCorrecter.configure do |config|
          config.post_tweets = true
        end
      end

      it 'should catch search exception and continue' do
        adapter.stubs(:search).with(any_parameters).raises(StandardError)
        adapter.expects(:reply_to).never

        controller.find_and_correct([correction_1])
      end

      it 'should catch reply exception and continue to next reply' do
        adapter.stubs(:search).returns(results)

        adapter.stubs(:reply_to).with(result_1, anything).raises(StandardError)
        adapter.expects(:reply_to).with(result_2, anything)
        adapter.expects(:reply_to).with(result_3, anything)

        controller.find_and_correct([correction_1])
      end
    end
  end

  describe 'posting tweets in between posting replies' do
    subject(:controller) { MrCorrecter::MrCorrecterController.new(adapter, logger, search_period) }

    before(:each) { adapter.stubs(:search).returns(results) }

    context 'when post_tweets is enabled' do
      before do
        MrCorrecter.configure do |config|
          config.post_tweets = true
          config.new_tweet_post_interval = 2
        end
      end

      after { MrCorrecter.reset }

      it 'should post a tweet at a regular interval' do
        adapter.expects(:reply_to).with(result_1, anything)
        adapter.expects(:reply_to).with(result_2, anything)
        adapter.expects(:send).with(anything)
        adapter.expects(:reply_to).with(result_3, anything)

        controller.find_and_correct([correction_1])
      end
    end

    context 'when post_tweets is disabled' do
      before do
        MrCorrecter.configure do |config|
          config.post_tweets = false
          config.new_tweet_post_interval = 2
        end
      end

      after { MrCorrecter.reset }

      it 'should reply to each tweet with a correcting tweet' do
        adapter.expects(:send).never

        controller.find_and_correct([correction_1])
      end
    end
  end
end
