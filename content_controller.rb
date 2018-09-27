class ContentController
  def initialize(contents)
    # 同時にセレクトリクエストをPOSTするクライアントは1つである前提
    @pool = Thread.pool(contents.size)
    @contents = contents
  end

  def switch(selected_id)
    @contents.each do |c|
      c[:selected] = (c[:id] == id)  
      if (c[:id] == selected_id)
        @pool.process { enable_content(c[:id], c[:target], true) }
      else
        @pool.process { enable_content(c[:id], c[:target], false) }
      end
    end
  end

  private

  def enable_content(id, target, is_enable)

    url = 'http://' + target +'/api/config'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    req = Net::HTTP::Post.new(uri.request_uri)
   
    req['Content-Type'] = 'application/json' # httpリクエストヘッダの追加
    config = ({'id': id ,'enable':is_enable}).to_json
    req.body = config # リクエストボディーにJSONをセット
    return http.request(req)
  end  
end
