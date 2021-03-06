require File.join(File.dirname(__FILE__), 'spec_helper')



describe Robetter do
 include Rack::Test::Methods

 def app
  @app ||= Robetter.new
 end

 before(:all) do
  @statuses1 = [ {'user' => {'profile_image_url'=>"http://p1.jpg",'screen_name'=>"user1"}, "text"=>"holamundo1"},
                 {'user' => {'profile_image_url'=>"http://p2.jpg",'screen_name'=>"user2"}, "text"=>"holamundo2"},
                 {'user' => {'profile_image_url'=>"http://p3.jpg",'screen_name'=>"user3"}, "text"=>"holamundo3"},
                 {'user' => {'profile_image_url'=>"http://p4.jpg",'screen_name'=>"user4"}, "text"=>"holamundo4"},
                 {'user' => {'profile_image_url'=>"http://p5.jpg",'screen_name'=>"user5"}, "text"=>"holamundo5"},
                 {'user' => {'profile_image_url'=>"http://p6.jpg",'screen_name'=>"user6"}, "text"=>"holamundo6"}
               ]
  @statuses  = [ {'user' => {'profile_image_url'=>"http://p1.jpg",'screen_name'=>"friend1"}, "text"=>"holamundo1"},
                 {'user' => {'profile_image_url'=>"http://p2.jpg",'screen_name'=>"friend2"}, "text"=>"holamundo2"},
                 {'user' => {'profile_image_url'=>"http://p3.jpg",'screen_name'=>"friend3"}, "text"=>"holamundo3"},
                 {'user' => {'profile_image_url'=>"http://p4.jpg",'screen_name'=>"friend4"}, "text"=>"@user hola"},
                 {'user' => {'profile_image_url'=>"http://p5.jpg",'screen_name'=>"friend5"}, "text"=>"holamundo5"},
                 {'user' => {'profile_image_url'=>"http://p6.jpg",'screen_name'=>"friend6"}, "text"=>"holamundo6"}
               ]
   @status = {'user' => {'profile_image_url'=>"http://p1.jpg",'screen_name'=>"user"}, "text"=>"heyyyyyyyy"}
   @authenticated_client = mock('TwitterOAuth::Client')
   @authenticated_client.stub!(:public_timeline).and_return(@statuses1)
   @authenticated_client.stub!(:friends_timeline).and_return(@statuses)
   @authenticated_client.stub!(:update).and_return{ @statuses.push(@status); return true }
   @authenticated_client.stub!(:mentions).and_return([@statuses[3]])
   @authenticated_client.stub!(:user_timeline).and_return(@statuses)
   
   @request_token = mock("request_token")
   @request_token.stub!(:token).and_return("token")
   @request_token.stub!(:secret).and_return("secret")
   @request_token.stub!(:authorize_url).and_return("http://api.twitter.com/oauth/access_token")
   @authenticated_client.stub!(:request_token).and_return(@request_token)
 end

 it "should get public timeline when user is not logged" do
  mock_client = mock('TwitterOAuth::Client')
  TwitterOAuth::Client.stub!(:new).and_return(mock_client)
  mock_client.stub!(:public_timeline).and_return(@statuses1)
  get '/', {}, {}
  last_response.body.include?("holamundo1").should be_true
 end

 it "should get user timeline when user is logged" do
  session[:user] = true
  TwitterOAuth::Client.stub!(:new).and_return(@authenticated_client)
  get '/', {}, {}
  last_response.body.include?("friend1").should be_true
 end
 
 it "should get user mentions when user is logged" do
  session[:user] = true
  TwitterOAuth::Client.stub!(:new).and_return(@authenticated_client)
  get '/mentions', {}, {}
  last_response.body.include?("@user").should be_true
 end

 it  "should update user's timeline" do
  session[:user] = true
  TwitterOAuth::Client.stub!(:new).and_return(@authenticated_client)
  post '/update', {:tweet =>"heyyyyyyyy"}, {}
  last_response.body.include?("heyyyyyyyy").should be_true
 end

 it "should update friends's timeline" do
  session[:user] = true
  TwitterOAuth::Client.stub!(:new).and_return(@authenticated_client)
  get '/friend1', {}, {}
  last_response.body.include?("holamundo1").should be_true
 end

 it "should redirect to twitter and connect" do
  get '/connect', {}, {}
  follow_redirect!
  pending
 end

 it "should authorize the client after connect" do
  pending
 end

 it "should logout the client" do
  get '/logout', {}, {}
  session[:user].should be_nil
  session[:request_token].should be_nil
  session[:request_token_secret].should be_nil
  session[:access_token].should be_nil
  session[:secret_token].should be_nil
 end

end