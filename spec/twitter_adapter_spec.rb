require 'spec_helper'

describe MrCorrecter::TwitterAdapter do

  let(:auth) do
    { consumer_key: 'ABDCD', consumer_secret: '12345',
      oauth_token: 'JFDSJKDFSJDSF', oauth_secret: 'PQPQASOPDASOPASPOP' }
  end

  let(:twitter_api) { mock }

  before(:each) do
    Twitter::REST::Client.stubs(:new).returns(twitter_api)
  end

  subject(:twitter) { MrCorrecter::TwitterAdapter.new(auth) }

  context 'when no auth param is supplied' do

    it 'should raise Exception' do
      expect { MrCorrecter::TwitterAdapter.new }.to raise_error(ArgumentError)
    end

  end

  describe '#search' do

    context 'when search text is empty' do

      it 'should not search Twitter' do
        twitter_api.expects(:search).with(anything).never
        twitter.search('')
      end

      it 'should return empty array' do
        expect(twitter.search('')).to eq([])
      end

    end

    context 'with search text' do

      let(:search_string) { 'foo' }

      let(:time_period) { 60 }

      let(:fake_results) do
        tweet1 = Twitter::Tweet.new(
                                      id: 'tweet1',
                                      created_at: Time.now.to_s
        )

        tweet2 = Twitter::Tweet.new(
                                      id: 'tweet2',
                                      created_at: (Time.now - time_period * 60).to_s # Time.now - seconds
        )

        [tweet1, tweet2]
      end

      it 'should ask twitter for results' do
        twitter_api.expects(:search).with("\"#{search_string}\"").once.returns([])
        twitter.search(search_string)
      end

      it 'should return results' do
        twitter_api.stubs(:search).returns(fake_results)
        results = twitter.search(search_string)

        expect(results).to eq(fake_results)
      end

      describe 'filtering search results' do

        context 'when time argument discounts one result' do

          it 'should only return results within time period' do
            twitter_api.stubs(:search).returns(fake_results)
            results = twitter.search(search_string, time_period)

            expect(results.length).to eq(1)
            expect(results.first.id).to eq(fake_results.first.id)
          end

        end

        context 'when time argument discounts no results' do

          it 'should return all results' do
            twitter_api.stubs(:search).returns(fake_results)
            results = twitter.search(search_string, (time_period + 1))

            expect(results.length).to eq(2)
            expect(results.first.id).to eq(fake_results.first.id)
            expect(results.last.id).to eq(fake_results.last.id)
          end

        end

      end

    end

  end

  describe '#send' do

    it 'should not do anything with empty text' do
      twitter_api.expects(:update).with(anything).never
      twitter.send('')
    end

    it 'should update twitter with text' do
      twitter_api.expects(:update).with('hello world', {}).once
      twitter.send('hello world')
    end

    it 'should take options' do
      opts = { test: 'foo' }
      twitter_api.expects(:update).with('hello world', opts).once
      twitter.send('hello world', opts)
    end

  end

  describe '#reply_to' do

    let(:tweet) do
      Twitter::Tweet.new(
                           id: 'tweet1',
                           created_at: Time.now.to_s,
                           user: {
                             screen_name: 'test_user',
                             id: 123_456
              }
      )
    end

    it 'should not do anything if tweet is nil' do
      twitter_api.expects(:update).with(anything).never
      twitter.reply_to(nil, 'hello world')
    end

    it 'should post to twitter with correct option and updated text' do
      opts = { in_reply_to_status: tweet }
      expected_text = "@#{tweet.user.screen_name} hello world"
      twitter_api.expects(:update).with(expected_text, opts).once
      twitter.reply_to(tweet, 'hello world')
    end

  end

end
