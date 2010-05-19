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

      columns = []
      data    = []

      if /^\s*show tables\s*$/i =~ params[:sql]
        columns = [:table_name]
        data    = db.tables.collect {|table| table.to_s }.sort.collect {|table| [table] }
      elsif match_data = params[:sql].match(/^\s*describe (\w+)\s*$/)
        schema  = db.schema(match_data[1])
        begin
          columns = ["Column", "Type", "Modifiers"]
          data = schema.collect do |column|
            hash = column.last
            modifiers = []
            modifiers << "primary key" if hash[:primary_key]
            modifiers << "not null" unless hash[:allow_null]
            modifiers << hash[:default] if hash[:default]
            [column.first, hash[:db_type], modifiers.join(" ")]
          end
        rescue Sequel::Error
          "Not a valid table name"
        end
      elsif match_data = params[:sql].match(/^\s*psql describe (\w+)\s*$/)
        if db.tables.collect {|table| table.to_s }.sort.collect {|table| [table] }.include?(match_data[1])
          require 'uri'

          url = URI.parse(params[:database_url])
          database = url.path.slice(1, url.path.size)

          ENV['PGPASSWORD'] = url.password

          `psql --host #{url.host} --username=#{url.user} #{database} -c '\d #{match_data[1]}'`
        else
          "Not a valid table name"
        end
      else
        query   = db[params[:sql]]
        rows    = query.all
        columns = query.columns

        data = rows.collect do |row|
          columns.collect { |column| row[column] }
        end
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
