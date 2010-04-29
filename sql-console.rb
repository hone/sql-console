require 'rubygems'
require 'bundler'
Bundler.setup(:default)
require 'sinatra/base'
require 'sequel'
require 'ruport'

class SqlConsole < Sinatra::Base
  get '/query' do
    "Please upgrade your sql-console plugin"
  end
end