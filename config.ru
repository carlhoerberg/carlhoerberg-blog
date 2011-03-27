require 'rubygems'
require 'bundler/setup'
require './lib/environment'
require './lib/app'

run Sinatra::Application
