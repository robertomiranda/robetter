require "rubygems"
require "bundler"
Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '..', 'twitter.rb')

require 'spec'
require 'spec/autorun'
require 'spec/interop/test'

set :enviorement, :test
set :session, true

FakeWeb.allow_net_connect = false

FakeWeb.register_uri(:post, 'http://api.twitter.com/oauth/request_token', :body => 'oauth_token=fake&oauth_token_secret=fake')
FakeWeb.register_uri(:post, 'http://api.twitter.com/oauth/access_token', :body => 'oauth_token=fake&oauth_token_secret=fake')
FakeWeb.register_uri(:get, 'http://twitter.com/account/verify_credentials.json', :response => File.join(File.dirname(__FILE__), 'verify_credentials.json'))
FakeWeb.register_uri(:get, "http://api.twitter.com/oauth/authenticate?oauth_token=fake", 
                     :status => ["301", "Moved Permanently"],  
                     :location => "localhost")

class SessionData
  def initialize(cookies)
    @cookies = cookies
    @data = cookies['rack.session']
    if @data
      @data = @data.unpack("m*").first
      @data = Marshal.load(@data)
    else
      @data = {}
    end
  end
  
  def [](key)
    @data[key]
  end
  
  def []=(key, value)
    @data[key] = value
    session_data = Marshal.dump(@data)
    session_data = [session_data].pack("m*")
    @cookies.merge("rack.session=#{Rack::Utils.escape(session_data)}", URI.parse("//example.org//"))
    raise "session variable not set" unless @cookies['rack.session'] == session_data
  end
end

def session
  SessionData.new(rack_test_session.instance_variable_get(:@rack_mock_session).cookie_jar)
end