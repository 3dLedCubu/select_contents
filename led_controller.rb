require 'resolv-replace'

class LEDController
  def initialize(host, port)
    @host = host
    @port = port
  end

  def light_off
    d = ([0]*8192).pack('C*')
    UDPSocket.open do |send_sock|
      begin
        send_sock_addr = Socket.pack_sockaddr_in(@port, @host)
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
