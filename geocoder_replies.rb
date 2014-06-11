require "twitter"
require "logger"
require "csv"
require "geocoder"

#
# Process all tweets,
# If reply, find the original tweet
# Geocode original tweet
#
# This is dodge :o
#

DEBUG = true
DEBUG_TWEET_LIMIT = 20

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['consumer_key']
  config.consumer_secret     = ENV['consumer_secret']
  config.access_token        = ENV['access_token']
  config.access_token_secret = ENV['access_token_secret']
end

def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    options = {:count => 200, :include_rts => true}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end

def is_number(value)
    true if Float(value) rescue false
end

# begin
tweets = client.get_all_tweets("mr_correcter")

correction_tweets = []

tweets.each do |mr_c_tweet|
  next unless mr_c_tweet.in_reply_to_status_id
  break if DEBUG && correction_tweets.size > DEBUG_TWEET_LIMIT

  result = []
  geo_located = false

  if DEBUG
    puts "id: #{mr_c_tweet.id}"
    puts "text: #{mr_c_tweet.text}"
    puts "reply_to id: #{mr_c_tweet.in_reply_to_status_id}"
    puts "to_user_id: #{mr_c_tweet.in_reply_to_user_id}"
  end
  puts "Processing Tweet #{mr_c_tweet.id}-#{mr_c_tweet.in_reply_to_screen_name}"
  result << mr_c_tweet.id
  result << mr_c_tweet.text
  result << mr_c_tweet.in_reply_to_status_id
  result << mr_c_tweet.in_reply_to_user_id
  result << mr_c_tweet.in_reply_to_screen_name


  begin
    reply_tweet = client.status(mr_c_tweet.in_reply_to_status_id)
    result << reply_tweet.text

    if reply_tweet.place?
      puts "Found Twitter.place" if DEBUG
      if reply_tweet.place.bounding_box?
        puts "Found Twitter.place.bounding_box" if DEBUG
        lon = reply_tweet.place.bounding_box.coordinates[0][0][0]#long
        lat = reply_tweet.place.bounding_box.coordinates[0][0][1]#lat

        geocoding_response = Geocoder.search("#{lat},#{lon}").first
      else
        puts "Geocoding Twitter.place" if DEBUG
        if reply_tweet.place.full_name
          placename = reply_tweet.place.full_name + ', ' + reply_tweet.place.country
        else
          placename = reply_tweet.country
        end

        geocoding_response = Geocoder.search(placename).first
        lon = geocoding_response.longitude
        lat = geocoding_response.latitude
      end

      result << lon
      result << lat

      result << "#{geocoding_response.city}, #{geocoding_response.country}" unless geocoding_response.nil?

    elsif reply_tweet.geo?
      puts "Found Twitter.geo" if DEBUG
      lon = reply_tweet.geo.coords[0]
      lat = reply_tweet.geo.coords[1]

      result << lon
      result << lat

      geocoding_response = Geocoder.search([lon, lat]).first
      result << "#{geocoding_response.city}, #{geocoding_response.country}" unless geocoding_response.nil?
    else
      puts "Attempting to Geocode Twitter user" if DEBUG
      usr_loc = client.user(reply_tweet.in_reply_to_user_id).location

      if usr_loc
        usr_loc_geo = Geocoder.search(usr_loc).first

        if usr_loc_geo
          result << usr_loc_geo.longitude
          result << usr_loc_geo.latitude
          result << "#{usr_loc_geo.city}, #{usr_loc_geo.country}"
        end

        result << usr_loc
      end
    end

  rescue Exception => e
    puts "Error: #{e.message}"
  end

  correction_tweets << result
end

CSV.open("mr-c-replies.csv", "wb", {:col_sep => ","}) do |csv|
  csv << %w(lat long username location original_tweet_status_id original_tweet reply_tweet_status_id reply_tweet)
  correction_tweets.each do |row|

      #in
  #mr_c-tweet_id,mr_c-tweet_text,reply_to-tweet id,reply_to_id,reply_to-username,reply_to-tweet_text,reply_long,reply_lat,reply_geo_loc
  #229803679073579008,@or_rain I think you meant to type accommodate,229749412459597824,18260972,"RT @ZodiacFacts: A #Pisces will accomodate people to the best of their limits, but if those limits are pushed or violated, they will get ...",-120.5542012,43.8041334,", United States",Oregon

  #out
  #lat,lon,user,description
  #lat,long,username,location,original_tweet_status_id,original_tweet,reply_tweet_status_id,reply_tweet
  #-1.2452,46.2242,TwitterUser,London England,blah,blah
  #-120.5542012,43.8041334,<h3>TwitterUser</h3>,180392,??

    lat = row[7]
    lon = row[6]
    title = ""
    desc = ""

    next unless is_number(lat) && is_number(lon)

    #only if we have lon & lat
    mr_ctweet_id = row[0]
    mr_ctweet_text = row[1]
    reply_to_tweet_id = row[2]
    reply_to_userid = row[3]
    reply_to_username = row[4]
    reply_to_tweet_text = row[5]
    reply_loc_str = row[8]

    csv << [lat, lon, reply_to_username, reply_loc_str, reply_to_tweet_id, reply_to_tweet_text, mr_ctweet_id, mr_ctweet_text]
  end
end

puts 'Done.'
