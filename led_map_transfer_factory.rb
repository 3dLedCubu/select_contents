require 'socket'
require 'timeout'

class LEDMapTransferFactory
  def initialize(queue)
    @queue = queue
  end

  def new_instance(content)
    if(content[:port] != nil)
      # for test
      # puts "create sock: " + content[:id]
      return lambda { transfer_from_sock(content) }
    else
      # for test
      # puts "create queue: " + content[:id]
      return lambda { transfer_from_queue(content) }
    end
  end

  private

  def transfer_from_sock(content)
    UDPSocket.open do |recv_sock|
      recv_sock.bind('0.0.0.0', content[:port])
      transfer content, lambda {
        begin
          Timeout::timeout(1) do
            recv_sock.recv(8192)
          end
        rescue Timeout::Error
          # to prevent zombie image
          ([0]*8192).pack('C*')
        end
        }
    end
  end

  def transfer_from_queue(content)
    transfer content, lambda { @queue.pop }
  end

  def transfer(content, producer)
    UDPSocket.open do |send_sock|
      # for test
      send_sock_addr = Socket.pack_sockaddr_in(9001, '192.168.0.10')
      # send_sock_addr = Socket.pack_sockaddr_in(9001, '127.0.0.1')
      while d = producer.call
        next unless content[:selected]
        send_sock.send(d, 0, send_sock_addr)
      end
    end
  end
end
