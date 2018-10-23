require 'timeout'
require 'socket'
require 'resolv-replace'

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
    @contents.each do |c|
      next unless c[:pool].done? 
      c[:selected] = (c[:id] == selected_id)  
      if (c[:id] == selected_id)
        @led_controller.light_off
        next if (c[:id]) == 'light_off'
      end
      c[:pool].process { enable_content(c, false) }
    end
  end

  private

  def enable_content(c, is_enable)

    begin
      url = 'http://' + get_ip_from_hostname(c[:target]) +'/api/config'
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, c[:port])
      http.use_ssl = false
      req = Net::HTTP::Post.new(uri.request_uri)
    
      req['Content-Type'] = 'application/json' # httpリクエストヘッダの追加
      config = ({'id': c[:id] ,'enable':is_enable}).to_json
      req.body = config # リクエストボディーにJSONをセット

      Timeout::timeout(@timeout) do
        res = http.request(req)
        c[:enable] = res.code == "200"
      end
    rescue => e
      p c[:target] + ": " + e.inspect
      c[:enable] = false
    end
  end

  def update_status(c)
    begin
      url = 'http://' + get_ip_from_hostname(c[:target]) +'/api/status'
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, c[:port])
      http.use_ssl = false
      req = Net::HTTP::Get.new(uri.request_uri)

      Timeout::timeout(@timeout) do
        res = http.request(req)
        c[:enable] = res.code == "200"
      end
    rescue => e
      p c[:target] + ": " + e.inspect
      c[:enable] = false
    end
  end

  def get_ip_from_hostname(hostname)
    Timeout::timeout(@timeout) do
      info =  Socket.getaddrinfo(hostname, nil, Socket::AF_INET)
      if info 
        info[0][3]
      else
        hostname
      end
    end
  end
end
