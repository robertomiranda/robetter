require 'rubygems'
require "sinatra"
require 'twitter_oauth'

configure do
  set :sessions, true
end

before do
#@@session={}
  @@config={'consumer_key'=>"xSYvtZj1TO0FVYB8G27Ew",
    'consumer_secret'=>"xXWtQyhspdGe39HPgjmB9qGYtjz4qFZbBZhXQ9qqHg"}
  @@config['callback_url'] = "http://localhost:4567/autho"
  @client = TwitterOAuth::Client.new(:consumer_key => @@config['consumer_key'],
  :consumer_secret => @@config['consumer_secret'])  

end

get '/' do  
  @tweets = @client.public_timeline  
  erb :home
end

get '/autho' do
    
p "-------------------"
p session[:request_token]
p session[:request_token_secret]
p params[:oauth_verifier]
#@client = TwitterOAuth::Client.new(:consumer_key => @@config['consumer_key'],
 # :consumer_secret => @@config['consumer_secret'],:token => session[:request_token], 
  #  :secret => session[:request_token_secret]) 
   # @tweets = @client.friends_timeline
    #erb :autho
    @access_token = @client.authorize(
     session[:request_token],
      session[:request_token_secret],
      :oauth_verifier => params[:oauth_verifier]
    )
    @tweets = @client.friends_timeline
p "-------------client twett.................."
p @client.methods.sort

    erb :autho

end

get '/connect' do  
  request_token = @client.request_token(:oauth_callback => @@config['callback_url'])
  p "---------------------connect-----------------------------------"
  p session[:request_token] = request_token.token  
  p session[:request_token_secret] = request_token.secret
  p session[:request_token]
  p session[:request_token_secret]
  redirect request_token.authorize_url.gsub('authorize', 'authenticate') 
end
