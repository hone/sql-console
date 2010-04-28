require 'rubygems'
require 'bundler'
Bundler.setup(:default)
require 'sinatra/base'
require 'sequel'
require 'ruport'

class SqlQuery < Sinatra::Base
  get '/query' do

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
        ""
      end

    rescue Sequel::DatabaseError => ex
      ex.message
    end
  end
end
