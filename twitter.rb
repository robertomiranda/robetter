require 'rubygems'
require "sinatra"
require 'twitter_oauth'

configure do
  set :sessions, true
end

before do  
  @@config={'consumer_key'=>"AFcCvgpKoilQY506lYPGJQ",
    'consumer_secret'=>"tRygHzQOlY9RofsVjEwhoDbTHJdULsx1bhBbbL82Jfs"}
  @@config['callback_url'] = "http://localhost:4567/connect/auth"
  @@client = TwitterOAuth::Client.new(:consumer_key => @@config['consumer_key'], 
                                      :consumer_secret => @@config['consumer_secret'],
                                      :token => session[:access_token],
                                      :secret => session[:secret_token]
                                      )
end

get '/' do  
  @tweets = @@client.public_timeline  
  erb :home
end

get '/timeline'do
  @tweets = @@client.friends_timeline
  erb :tweets
end

post '/update' do
  p ".--------------------------------update-------------------------------"
  @@client.update(params[:tweet])
  redirect "/timeline"
end

get '/mentions' do
  
  @tweets = @@client.mentions
  p ".--------------------------------mentions-------------------------------"
  p @tweets
  erb :tweets
end

get '/connect/auth' do  

  begin
  session[:oauth_verifier] = params[:oauth_verifier] if params[:oauth_verifier]
  @access_token = @@client.authorize(
     session[:request_token],
      session[:request_token_secret],
      :oauth_verifier => session[:oauth_verifier]
    )
  rescue OAuth::Unauthorized
  end
  
  if @@client.authorized?    
      session[:access_token] = @access_token.token
      session[:secret_token] = @access_token.secret
      session[:user] = true
      redirect '/timeline'
    else
      redirect '/'
  end    
  
end



get '/connect' do  
  request_token = @@client.request_token(:oauth_callback => @@config['callback_url'])
  p "---------------------connect-----------------------------------"
  p session[:request_token] = request_token.token  
  p session[:request_token_secret] = request_token.secret
  p session[:request_token]
  p session[:request_token_secret]
  redirect request_token.authorize_url.gsub('authorize', 'authenticate') 
end
