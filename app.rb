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
    haml :index, locals: { title: 'select contents' }
  end
end
