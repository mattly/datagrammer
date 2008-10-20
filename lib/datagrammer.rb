require 'socket'

$:.unshift File.dirname(__FILE__)
require 'datagrammer/packet'
require 'datagrammer/packet_scanner'

class Datagrammer
  def initialize(listening_port, sending_port=nil, address="0.0.0.0")
    sending_port ||= listening_port + 1
    @listening_port, @sending_port, @address = listening_port, sending_port, address
    @socket = UDPSocket.new
    @socket.bind(@address, @listening_port)
    listen
  end
  
  attr_accessor :thread, :socket, :address
  
  def listen(&block)
    @thread = Thread.start do
      loop do
        IO.select([@socket])
        data, info = @socket.recvfrom(65535)
        block.call(self, Packet.decode(data), info)
      end
    end
  end
  
  def reply(*message)
    @socket.send(Packet.encode([message]), 0, @address, @sending_port)
  end
  
end