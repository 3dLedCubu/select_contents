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

  def flow(content)
    d = UDPSocket.open do |udps|
      udps.bind('0.0.0.0', content[:port])
      udps.recv(8192)
    end
    return unless content[:selected]
    UDPSocket.open do |udp|
      sockaddr = Socket.pack_sockaddr_in(5001, '127.0.0.1')
      udp.send(d, 0, sockaddr)
    end
  end

  def initialize
    super
    @contents = [
      { id: 'lego', name: 'LEGO', port: 5101, selected: false },
      { id: 'screen_saver', name: 'SCREEN SAVER', port: 5201, selected: false },
      { id: 'paint', name: 'PAINT', port: 5301, selected: false },
      { id: 'hello', name: 'HELLO', port: 5401, selected: false }
    ]
    @contents.each { |c| Thread.new { loop { flow(c) } } }
  end

  get '/' do
    @contents = [
      { id: 'lego', name: 'LEGO', port: 5101, selected: false },
      { id: 'screen_saver', name: 'SCREEN SAVER', port: 5201, selected: false },
      { id: 'paint', name: 'PAINT', port: 5301, selected: false },
      { id: 'hello', name: 'HELLO', port: 5401, selected: false }
    ]
    haml :index, locals: { title: 'select contents' }
  end

  get '/index.js' do
    coffee :index
  end
end
