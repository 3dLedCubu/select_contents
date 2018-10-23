require 'timeout'
require 'socket'

module MyUtils
  def self.get_ip_from_hostname(hostname)
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
