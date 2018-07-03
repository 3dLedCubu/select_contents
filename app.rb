# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'socket'

# $contents = [
#   { id: 'lego', name: 'ブロック', port: 5101, selected: false },
#   { id: 'screen_saver', name: 'デモ', port: 5201, selected: false },
#   { id: 'paint', name: 'おえかき', port: 5301, selected: false },
#   { id: 'camera', name: 'カメラ', port: 5401, selected: false },
#   { id: 'kusogame', name: 'クソゲー', port: 5501, selected: false }
# ]

$large_contents = [
  { id: 'lego', name: 'ブロック', port: 5101, selected: false },
  { id: 'paint', name: 'おえかき', port: 5301, selected: false },
  { id: 'camera', name: 'カメラ', port: 5401, selected: false }
]

$small_contents = [
  { id: 'screen_saver', name: 'デモ', port: 5201, selected: false },
  { id: 'kusogame', name: 'クソゲー', port: 5501, selected: false }
]

##
# Server program
class App < Sinatra::Base
  register Sinatra::Reloader
  enable :sessions
  set :bind, '0.0.0.0' # 外部アクセス可

  def flow(content)
    d = UDPSocket.open do |udps|
      udps.bind('0.0.0.0', content[:port])
      udps.recv(8192)
    end
    return unless content[:selected]
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
    #@contents = $contents
    @large_contents = $large_contents
    @small_contents = $small_contents
    haml :index, locals: { title: '3D LED' }
  end

  post '/select' do
    id = params['id']
    $contents.each do |c|
      # c[:selected] = (c[:id] == id)
      if(c[:selected]== false && c[:id] == id)
        c[:selected] = true
      else
        c[:selected] = false
      end
    end
    p ({ select: $contents }).to_json 
  end
end
