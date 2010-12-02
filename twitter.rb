require 'rubygems'
require "sinatra"
require 'twitter_oauth'

before do
  @@config={'consumer_key'=>"143901814-yHmhBvtty49RuNB2edzapnHCyS4sKXpUAkATCjns",
    'consumer_secret'=>"eLPQmj2rQM65EN3DU4MSMJH5tr9OQI96IohtsUByxHk"}
  @client = TwitterOAuth::Client.new(:consumer_key => @@config['consumer_key'],
  :consumer_secret => @@config['consumer_secret'])  
end

get '/' do
  @trends = @client.current_trends
  @tweets = @client.public_timeline
  erb:home
end
