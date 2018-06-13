# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'coffee-script'
require 'socket'

##
# Server program
class App < Sinatra::Base
  register Sinatra::Reloader
  enable :sessions
  set :bind, '0.0.0.0' # 外部アクセス可
  Tilt::CoffeeScriptTemplate.default_bare = true # coffeescriptの即時関数を外す

  get '/' do
    @contents = [
      { id: 'lego', name: 'LEGO', port: 5101 },
      { id: 'screen_saver', name: 'SCREEN SAVER', port: 5201 },
      { id: 'paint', name: 'PAINT', port: 5301 },
    ]
    haml :index, locals: { title: 'select contents' }
  end

  get '/index.js' do
    coffee :index
  end
end
