require 'socket'
require 'timeout'

class LEDMapTransferFactory
  def initialize(queue, host, port)
    @queue = queue
    @host = host
    @port = port
  end

  def new_instance(content)
    return lambda { transfer content, lambda { @queue.pop } }
  end

  private

  def transfer(content, producer)
    UDPSocket.open do |send_sock|
      # for test
      send_sock_addr = Socket.pack_sockaddr_in(@port, @host)
      # send_sock_addr = Socket.pack_sockaddr_in(9001, '127.0.0.1')
      while d = producer.call
        next unless content[:selected]
        send_sock.send(d, 0, send_sock_addr)
      end
    end
  end
end
