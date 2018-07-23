# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

require 'net/http'
require 'uri'
require 'thread/pool'

require './led_controller'
require './audio_controller'

$large_contents = [
  { id: 'lego', name: 'ブロック', port: 5101, sound_port: 5000, selected: false, unselect_img: 'assets/kit_btn_main01_off.png', select_img: 'assets/kit_btn_main01_on.png' },
  { id: 'paint', name: 'おえかき', port: 5301, sound_port: 5302, selected: false, unselect_img: 'assets/kit_btn_main02_off.png', select_img: 'assets/kit_btn_main02_on.png' },
  { id: 'camera', name: 'カメラ', port: 5401, sound_port: 5402, selected: false, unselect_img: 'assets/kit_btn_main03_off.png', select_img: 'assets/kit_btn_main03_on.png' }
]

$small_contents = [
  { id: 'screen_saver', name: 'デモ', port: 5201, selected: false, unselect_img: 'assets/Kit_btn_Demo_Off.png', select_img: 'assets/Kit_btn_Demo_On.png'  }
]

$light_off_contents = [
  { id: 'light_off', name: '消灯', port: nil, selected: true, unselect_img: 'assets/Kit_btn_LED_On.png', select_img: 'assets/Kit_btn_LED_Off.png'  }
]

$contents = $large_contents + $small_contents + $light_off_contents

##
# Server program
class App < Sinatra::Base
  register Sinatra::Reloader
  enable :sessions
  set :bind, '0.0.0.0' # 外部アクセス可

  def initialize
    super
    @led_controller = LEDController.new $contents
    @audio_controller = AudioController.new $large_contents
  end

  get '/' do
    @led_controller.light_off

    @large_contents = $large_contents
    @small_contents = $small_contents
    @light_off_contents = $light_off_contents
    haml :index, locals: { title: '3D LED' }
  end

  post '/select' do
    id = params['id']

    @led_controller.switch id
    @audio_controller.switch id

    if(id == 'light_off')
      @led_controller.light_off
    end

    return true 
  end

end
