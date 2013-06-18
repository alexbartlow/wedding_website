require "rubygems"
require "bundler/setup"
require 'rack'
require 'sinatra/base'
require 'coffee-script'
require 'slim'
require 'json'
require 'google_drive'
GOOGLE_LOGIN = ENV['GOOGLE_LOGIN']
GOOGLE_PASSWORD = ENV['GOOGLE_PASSWORD']
SPREADSHEET_KEY= ENV['SPREADSHEET_KEY']

Dir[File.expand_path('../lib/**/*.rb', __FILE__)].each {|f| STDERR.puts f ; require f}

def File.slideify(path)
  File.read(path).gsub(/</, '&lt;').gsub(/>/, '&gt;').gsub(/\[/, '<').gsub(/\]/, '>')
end

class App < Sinatra::Base
  helpers Helpers::Links
  set :slim, :layout_engine => :erb, :layout => :layout

  def setup_ws
    session = GoogleDrive.login(GOOGLE_LOGIN, GOOGLE_PASSWORD)
    session.spreadsheet_by_key(SPREADSHEET_KEY).worksheets[0]
  end

  def set_record(data, verb, count)
    ws = setup_ws
    row = (1..ws.num_rows).detect do |r|
      ws[r, 1] == data['first_name'] &&
      ws[r, 2] == data["last_name"]
    end
    if row
      ws[row, 6] = verb
      ws[row, 7] = count
      ws.save
    end
  end

  get '/favicon.ico' do
    not_found
  end

  get '/last_name' do
    content_type :json
    ws = setup_ws
    last_names_matching = ws.rows.select do |row|
      row[1].downcase == params[:last_name].downcase
    end

    last_names_matching.map do |row|
      next unless row[4]
      {
        :first_name => row[0],
        :last_name  => row[1],
        :invitees      => (1..(row[4].to_i)).to_a
      }
    end.to_json
  end

  post '/accept' do
    content_type :json
    data = JSON.parse(request.body.read.to_s)
    set_record(data, 'attending', data['attending'])
    STDERR.puts data.inspect
  end

  post '/decline' do
    content_type :json
    data = JSON.parse(request.body.read.to_s)
    set_record(data, 'declined', 0)
    STDERR.puts data.inspect
  end

  get '/' do
    slim :index
  end

  get '/:path' do
    erb params[:path].to_sym rescue slim params[:path].to_sym
  end

  get '/coffeescripts/:path' do
    coffee params[:path].to_sym
  end
  
end

map '/' do
  run App.new
end



