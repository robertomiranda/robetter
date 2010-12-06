require "rubygems"
require "bundler"
Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '..', 'twitter.rb')

require 'spec'
require 'spec/autorun'
require 'spec/interop/test'

set :enviorement, :test
set :session, true