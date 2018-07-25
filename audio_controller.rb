class AudioController
  def initialize(large_contents)
    # 同時にセレクトリクエストをPOSTするクライアントは1つである前提
    @pool = Thread.pool(large_contents.size)
    @large_contents = large_contents
  end

  def switch(selected_id)
    @large_contents.each do |c|
      if (c[:id] == selected_id)
        @pool.process { send_volume(c[:sound_port], 100) }
      else
        @pool.process { send_volume(c[:sound_port], 0) }
      end
    end
  end

  private

  def send_volume(sound_port, volume)
    # for test
    url = 'http://192.168.0.20:'+sound_port.to_s+'/api/audio'
    # url = 'http://localhost:4567/api/audio'
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
