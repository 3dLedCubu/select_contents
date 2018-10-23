require 'resolv-replace'

require './my_utils'

class LEDController
  def initialize(host, port)
    @host = host
    @port = port
    @pool = Thread::Pool.new(1)
    @m = Mutex.new
  end

  def light_off
    @pool.process{send_empty_data}
  end

  def set_host_and_port(host, port)
    @m.synchronize {
      @host = host
      @port = port
    }
  end

  def is_host_and_port_same?(host, port)
    return @host == host && @port == port
  end

  def host
    @m.synchronize {
      @host
    }    
  end
  def port
    @m.synchronize {
      @port
    }
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
