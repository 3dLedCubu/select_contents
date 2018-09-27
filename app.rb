# frozen_string_literal: true
Encoding.default_external = 'UTF-8'
require 'sinatra'
require 'sinatra/reloader'
require 'json'

require 'net/http'
require 'uri'
require 'thread/pool'

require './led_controller'
require './content_controller'

$large_contents = [
  { id: 'lego', target: 'localhost:3002', name: 'ブロック', enable:false, selected: false, unselect_img: 'assets/kit_btn_main01_off.png', select_img: 'assets/kit_btn_main01_on.png' },
  { id: 'paint', target: 'localhost:3002', name: 'おえかき',enable:false, selected: false, unselect_img: 'assets/kit_btn_main02_off.png', select_img: 'assets/kit_btn_main02_on.png' },
  { id: 'camera', target: 'localhost:3002', name: 'カメラ', enable:false, selected: false, unselect_img: 'assets/kit_btn_main03_off.png', select_img: 'assets/kit_btn_main03_on.png' }
]

$small_contents = [
  { id: 'screen_saver', target: 'localhost:3002', name: 'デモ', enable:false, selected: false, unselect_img: 'assets/Kit_btn_Demo_Off.png', select_img: 'assets/Kit_btn_Demo_On.png'  }
]

$light_off_contents = [
  { id: 'light_off', name: '消灯', enable:false, selected: true, unselect_img: 'assets/Kit_btn_LED_On.png', select_img: 'assets/Kit_btn_LED_Off.png'  }
]

$contents = $large_contents + $small_contents + $light_off_contents

##
# Server program
class App < Sinatra::Base
  register Sinatra::Reloader
  enable :sessions
  set :bind, '0.0.0.0'# 外部アクセス可
  set :port, 3001

  def initialize
    super
    @led_controller = LEDController.new '172.27.175.176', 9001
    @content_countroller = ContentController.new $large_contents + $small_contents
  end

  get '/' do
    @led_controller.light_off

    @large_contents = $large_contents
    @small_contents = $small_contents
    @light_off_contents = $light_off_contents
    haml :index, locals: { title: '3D LED' }
  end

  get '/status' do
    @content_countroller.status.to_json
  end

  post '/select' do
    id = params['id']

    @content_countroller.switch id

    if(id == 'light_off')
      @led_controller.light_off
    end

    return true 
  end

end
