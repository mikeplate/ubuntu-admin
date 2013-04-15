require 'sinatra'
require 'sass'

set :environment, :development
require 'sinatra/reloader'
configure(:development) do |cfg|
    cfg.also_reload('data/*.rb')
end

get '/*.css' do
    scss params[:splat][0].to_sym
end

require './app.rb'

require 'debugger'
require 'rack/debug'
use Rack::Debug

run Sinatra::Application

