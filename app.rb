# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'socket'

require 'net/http'
require 'uri'

$large_contents = [
  { id: 'lego', name: 'ブロック', port: 5101, sound_port: 5000, selected: false, unselect_img: 'assets/kit_btn_main01_off.png', select_img: 'assets/kit_btn_main01_on.png' },
  { id: 'paint', name: 'おえかき', port: 5301, sound_port: 5302, selected: false, unselect_img: 'assets/kit_btn_main02_off.png', select_img: 'assets/kit_btn_main02_on.png' },
  { id: 'camera', name: 'カメラ', port: 5401, sound_port: 5402, selected: false, unselect_img: 'assets/kit_btn_main03_off.png', select_img: 'assets/kit_btn_main03_on.png' }
]
# $large_contents = [
#   { id: 'lego', name: 'ブロック', sound_port: 5000, selected: false, unselect_img: 'assets/block1.png', select_img: 'assets/block2.png'  },
#   { id: 'paint', name: 'おえかき', sound_port: 5000, selected: false, unselect_img: 'assets/paint1.png', select_img: 'assets/paint2.png'  },
#   { id: 'camera', name: 'カメラ', sound_port: 5000, selected: false, unselect_img: 'assets/camera1.png', select_img: 'assets/camera2.png' }
# ]

$small_contents = [
  { id: 'screen_saver', name: 'デモ', port: 5201, selected: false, unselect_img: 'assets/Kit_btn_Demo_Off.png', select_img: 'assets/Kit_btn_Demo_On.png'  }
]

$light_off_contents = [
  { id: 'light_off', name: '消灯', port: 5001, selected: true, unselect_img: 'assets/Kit_btn_LED_On.png', select_img: 'assets/Kit_btn_LED_Off.png'  }
]

$contents = $large_contents + $small_contents + $light_off_contents

##

# Server program
class App < Sinatra::Base
  register Sinatra::Reloader
  enable :sessions
  set :bind, '0.0.0.0' # 外部アクセス可

  # for test
  def recv_image_dummy
    d = UDPSocket.open do |udps|
      udps.bind('0.0.0.0', 9001)
      udps.recv(8192)
    end
    puts 'received'
  end

  def flow(content)
    UDPSocket.open do |recv_sock|
      recv_sock.bind('0.0.0.0', content[:port])
      UDPSocket.open do |send_sock|
        # for test
        # send_sock_addr = Socket.pack_sockaddr_in(9001, '192.168.0.10')
        send_sock_addr = Socket.pack_sockaddr_in(9001, '127.0.0.1')
        loop do
          d = recv_sock.recv(8192)
          next unless content[:selected]
          send_sock.send(d, 0, send_sock_addr)
        end
      end
    end
  end

  def send_light_off
    d = ([0]*8192).pack('C*')
    UDPSocket.open do |udp|
      sockaddr = Socket.pack_sockaddr_in(5001, '127.0.0.1')
      udp.send(d, 0, sockaddr)
    end
  end

  def initialize
    super
    $contents.each { |c| Thread.new { flow(c) } }
    # for test
    Thread.new { loop { recv_image_dummy() } }
  end

  get '/' do
    @large_contents = $large_contents
    @small_contents = $small_contents
    @light_off_contents = $light_off_contents
    haml :index, locals: { title: '3D LED' }
  end

  post '/select' do
    id = params['id']

    # $large_contents.each do |c|
    #   if (c[:id] == id)
    #     select_volume(c[:sound_port],100)
    #   else
    #     select_volume(c[:sound_port],0)
    #   end
    # end

    if(id == 'light_off')
      send_light_off
    end

    $contents.each do |c|
      c[:selected] = (c[:id] == id)  
    end
    p ({ select: $contents }).to_json 
  end

  # for test
  post '/api/audio' do
    params = JSON.parse request.body.read
    volume = params['volume']
  end

  def select_volume(sound_port, volume)
    url = 'http://192.168.0.20:'+sound_port.to_s+'/api/audio'
    #url = 'http://localhost:'+sound_port.to_s+'/api/audio'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    req = Net::HTTP::Post.new(uri.request_uri)
   
    req['Content-Type'] = 'application/json' # httpリクエストヘッダの追加
    vol = ({'volume':volume}).to_json
    req.body = vol # リクエストボディーにJSONをセット
    return http.request(req)
  end
end
