# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'coffee-script'
require 'socket'

$contents = [
  { id: 'lego', name: 'ブロック', port: 5101, selected: false },
  { id: 'screen_saver', name: 'デモ', port: 5201, selected: false },
  { id: 'paint', name: 'おえかき', port: 5301, selected: false },
  { id: 'hello', name: 'こんにちは', port: 5401, selected: false }
]

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
    p content[:selected]
    return unless content[:selected]
    puts 'hoge'
    UDPSocket.open do |udp|
      sockaddr = Socket.pack_sockaddr_in(9001, '192.168.0.10')
      udp.send(d, 0, sockaddr)
    end
  end

  def initialize
    super
    $contents.each { |c| Thread.new { loop { flow(c) } } }
  end

  get '/' do
    @contents = $contents
    haml :index, locals: { title: '3D LED' }
  end

  post '/select' do
    id = params['id']
    $contents.each do |c|
      c[:selected] = (c[:id] == id)
    end
    p ({ select: $contents }).to_json
  end
end
