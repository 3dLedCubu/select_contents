require 'timeout'
require 'resolv-replace'

require './my_utils'

class ContentController
  def initialize(contents, led_controller, timeout=0.1)
    # 同時にセレクトリクエストをPOSTするクライアントは1つである前提
    @led_controller = led_controller
    @contents = contents
    @contents.each  do |c|
      c[:pool] = Thread::Pool.new(1)
    end

    @timeout = timeout
  end

  def status
    @contents.each do |c|
      next unless c[:pool].done? 
      c[:pool].process { update_status(c)} 
    end
    @contents
  end

  def switch(selected_id)
    @led_controller.light_off
    @contents.each do |c|
      c[:selected] = c[:id] == selected_id
      next unless c[:pool].done? 
      next unless c[:is_alive]
      c[:pool].process { enable_content(c, c[:selected]) }
    end
  end

  private

  def enable_content(c, is_enable)

    begin
      url = 'http://' + MyUtils.get_ip_from_hostname(c[:target]) +'/api/config'
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, c[:port])
      http.use_ssl = false
      req = Net::HTTP::Post.new(uri.request_uri)
    
      req['Content-Type'] = 'application/json' # httpリクエストヘッダの追加
      config = ({'id': c[:id] ,'enable':is_enable}).to_json
      req.body = config # リクエストボディーにJSONをセット

      Timeout::timeout(@timeout) do
        res = http.request(req)
        c[:is_alive] = res.code == "200"
      end
    rescue => e
      p c[:target] + ": " + e.inspect
      c[:is_alive] = false
    end
  end

  def update_status(c)
    p c[:selected]
    begin
      url = 'http://' + MyUtils.get_ip_from_hostname(c[:target]) +'/api/status'
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, c[:port])
      http.use_ssl = false
      req = Net::HTTP::Get.new(uri.request_uri)

      Timeout::timeout(@timeout) do
        res = http.request(req)
        c[:is_alive] = res.code == "200"

        if res.code == "200"
          state = JSON.parse(res.body)
          host, port = state["target"].split(":")
          unless @led_controller.is_host_and_port_same?(host, port)
            p "warning.. deferrent hosts or ports is mixed in targets. "
          end
          @led_controller.set_host_and_port(host, port)

          enable_content(c, c[:selected])
        end

      end
    rescue => e
      p c[:target] + ": " + e.inspect
      c[:is_alive] = false
    end
  end
end
