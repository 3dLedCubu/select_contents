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
  { id: 'lego', target: 'block-identifier.local', port:'5001', name: 'ブロック', is_alive:false, selected: false, unselect_img: 'assets/kit_btn_main01_off.png', select_img: 'assets/kit_btn_main01_on.png', press_img: 'assets/kit_btn_main01_press.png' },
  { id: 'paint', target: 'painting.local', port:'5001', name: 'おえかき',is_alive:false, selected: false, unselect_img: 'assets/kit_btn_main02_off.png', select_img: 'assets/kit_btn_main02_on.png', press_img: 'assets/kit_btn_main02_press.png' },
  { id: 'camera', target: 'hitokage.local', port:'5001', name: 'カメラ', is_alive:false, selected: false, unselect_img: 'assets/kit_btn_main03_off.png', select_img: 'assets/kit_btn_main03_on.png', press_img: 'assets/kit_btn_main03_press.png' }
]

$small_contents = [
  { id: 'screen_saver', target: 'mori-san.local', port:'5001', name: 'デモ', is_alive:false, selected: false, unselect_img: 'assets/kit_btn_demo_off.png', select_img: 'assets/kit_btn_demo_on.png', press_img: 'assets/kit_btn_demo_press.png' }
]

$light_off_contents = [
  { id: 'light_off', name: '消灯', is_alive:true, selected: true, unselect_img: 'assets/kit_btn_led_on.png', select_img: 'assets/kit_btn_led_off.png', press_img: 'assets/kit_btn_led_press.png' }
]

$contents = $large_contents + $small_contents + $light_off_contents

##
# Server program
class App < Sinatra::Base
  register Sinatra::Reloader
  enable :sessions
  set :bind, '0.0.0.0'# 外部アクセス可
  set :port, 80

  def initialize
    super
    #led_controller's hostname and port will overwrite by content_controller's status response.
    led_controller = LEDController.new '3d-led-cube.local', 9001 
    @content_countroller = ContentController.new $large_contents + $small_contents, led_controller
  end

  get '/' do
    @content_countroller.switch 'light_off'

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

    return true 
  end

end
