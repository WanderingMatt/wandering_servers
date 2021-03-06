require 'socket'
require 'ipaddr'

class ChatMulticast
  VERSION = '1.0.0'

  MULTICAST_ADDR = "234.5.6.7"
  PORT = 7387

  def self.run
    receive = Thread.new do
      ip =  IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new("0.0.0.0").hton
      sock = UDPSocket.new
      sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
      sock.bind(Socket::INADDR_ANY, PORT)
      loop do
        message, info = sock.recvfrom(1024)
        puts message
      end
    end

    send = Thread.new do
      user = `echo $USER`.chomp.capitalize
      begin
        socket = UDPSocket.open
        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, [1].pack('i'))
        socket.send("** #{user} joined **", 0, MULTICAST_ADDR, PORT)
        loop do
          typed = gets.chomp
          message = "#{user}: #{typed}"
          if typed =~ /^(exit|quit|stop)$/i
            socket.send("** #{user} left **", 0, MULTICAST_ADDR, PORT)
            break
          end
          socket.send(message, 0, MULTICAST_ADDR, PORT)
        end
      ensure
        socket.close 
      end
    end
    send.join
  end
end