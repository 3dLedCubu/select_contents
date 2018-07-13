# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'socket'

require 'net/http'
require 'uri'

$large_contents = [
  { id: 'lego', name: 'ブロック', port: 5000, selected: false },
  { id: 'paint', name: 'おえかき', port: 5301, selected: false },
  { id: 'camera', name: 'カメラ', port: 5401, selected: false }
]

$small_contents = [
  { id: 'screen_saver', name: 'デモ', port: 5201, selected: false }
]

$lower_right_contents = [
  { id: 'light_off', name: '消灯', port: 5501, selected: false }
]

$contents = $large_contents + $small_contents + $lower_right_contents


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
    @lower_right_contents = $lower_right_contents
    haml :index, locals: { title: '3D LED' }
  end

  post '/select' do
    id = params['id']

    # $contents.each do |c|
    #   if (c[:id] == id)
    #     port = c[:port] 
    #   end 
    # end

    # URL = 'http://192.168.0.20:'+port+'/api/audio'

    # uri = URI.parse(URL)
    # https = Net::HTTP.new(uri.host, uri.port)
     
    # https.use_ssl = true # HTTPSでよろしく
    # req = Net::HTTP::Post.new(uri.request_uri)
     
    # req['Content-Type'] = 'application/json' # httpリクエストヘッダの追加
    # vol({"volume":100}).to_json
    # req.body = vol # リクエストボデーにJSONをセット


    $contents.each do |c|
      c[:selected] = (c[:id] == id)  
    end
    p ({ select: $contents }).to_json 
  end

  post '/api/audio' do
    params = JSON.parse request.body.read
    volume = params['volume']
  end
end
