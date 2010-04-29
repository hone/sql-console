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

  post '/query' do
    begin
      db      = Sequel.connect(params[:database_url])
      query   = db[params[:sql]]

      rows    = query.all
      columns = query.columns

      data = rows.collect do |row|
        columns.collect { |column| row[column] }
      end

      if columns.length > 0
        Table(:data => data, :column_names => columns).as(:text, :ignore_table_width => true)
      else
        "OK"
      end

    rescue Sequel::DatabaseError => ex
      ex.message
    end
  end
end
