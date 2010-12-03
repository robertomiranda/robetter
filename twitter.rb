require 'rubygems'
require "sinatra"
require 'twitter_oauth'

configure do
  @@config = {'consumer_key'=>"AFcCvgpKoilQY506lYPGJQ", 'consumer_secret'=>"tRygHzQOlY9RofsVjEwhoDbTHJdULsx1bhBbbL82Jfs",
              'callback_url' => "http://localhost:4567/connect/auth"}
  set :sessions, true
end

before do  
  @client = TwitterOAuth::Client.new(:consumer_key => @@config['consumer_key'], :consumer_secret => @@config['consumer_secret'], 
                                     :token => session[:access_token], :secret => session[:secret_token])
end

get '/' do  
  @tweets = @client.public_timeline  
  erb :home
end

get '/timeline'do
  @tweets = @client.friends_timeline
  erb :tweets
end

post '/update' do
  p ".--------------------------------update-------------------------------"
  @client.update(params[:tweet])
  redirect "/timeline"
end

get '/mentions' do
  p ".--------------------------------mentions-------------------------------"
  @tweets = @client.mentions
  erb :tweets
end

get '/connect/auth' do  

  begin
  session[:oauth_verifier] = params[:oauth_verifier] if params[:oauth_verifier]
  @access_token = @client.authorize(session[:request_token], session[:request_token_secret],
                    :oauth_verifier => session[:oauth_verifier])
  rescue OAuth::Unauthorized ; end
  
  if @client.authorized?    
      session[:access_token] = @access_token.token
      session[:secret_token] = @access_token.secret
      redirect '/timeline'
    else
      redirect '/'
  end    
  
end

get '/connect' do  
  p "---------------------connect-----------------------------------"
  request_token = @client.request_token(:oauth_callback => @@config['callback_url'])
  session[:request_token] = request_token.token  
  session[:request_token_secret] = request_token.secret
  redirect request_token.authorize_url.gsub('authorize', 'authenticate') 
end
