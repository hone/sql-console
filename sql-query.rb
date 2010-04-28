require 'rubygems'
require 'bundler'
Bundler.setup(:default)
require 'sinatra/base'
require 'sequel'
require 'ruport'

class SqlQuery < Sinatra::Base
  get '/query' do
    db = Sequel.connect(params[:database_url])
    query = db[params[:sql]]
    columns = query.columns
    data = query.collect do |row|
      columns.collect {|column| row[column] }
    end

    Table(:data => data, :column_names => columns).to_s
  end
end
