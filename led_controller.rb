require 'resolv-replace'

require './my_utils'

class LEDController
  def initialize(host, port)
    @host = host
    @port = port
    @pool = Thread::Pool.new(1)
  end

  def light_off
    @pool.process{send_empty_data}
  end

  private

  def send_empty_data
    d = ([0]*8192).pack('C*')
    UDPSocket.open do |send_sock|
      begin
        sleep(0.5)
        send_sock_addr = Socket.pack_sockaddr_in(@port, MyUtils.get_ip_from_hostname(@host))
        Timeout::timeout(0.2) do
          send_sock.send(d, 0, send_sock_addr)
        end
      rescue Timeout::Error
        p @host + " was timeout."
      rescue
        p "connection failed - host:" + @host
      end
    end
  end
end
