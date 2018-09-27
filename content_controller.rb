require 'timeout'

class ContentController
  def initialize(contents)
    # 同時にセレクトリクエストをPOSTするクライアントは1つである前提
    @pool = Thread.pool(contents.size)
    @contents = contents
  end

  def status
    @contents.each do |c|
      url = 'http://' + c[:target] +'/api/config'
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = false
      req = Net::HTTP::Get.new(uri.request_uri)
  
      begin
        Timeout::timeout(0.5) do
          http.request(req)
          c[:enable] = true
        end
      rescue
        c[:enable] = false
      end
    end 
    @contents
  end

  def switch(selected_id)
    @contents.each do |c|
      c[:selected] = (c[:id] == selected_id)  
      if (c[:id] == selected_id)
        @pool.process { enable_content(c, true) }
      else
        @pool.process { enable_content(c, false) }
      end
    end
  end

  private

  def enable_content(c, is_enable)

    url = 'http://' + c[:target] +'/api/config'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    req = Net::HTTP::Post.new(uri.request_uri)
   
    req['Content-Type'] = 'application/json' # httpリクエストヘッダの追加
    config = ({'id': c[:id] ,'enable':is_enable}).to_json
    req.body = config # リクエストボディーにJSONをセット

    begin
      Timeout::timeout(0.5) do
        http.request(req)
        c[:enable] = true
      end
    rescue Timeout::Error
      c[:enable] = false
    end
  end
end
