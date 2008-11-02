require 'socket'

$:.unshift File.dirname(__FILE__)
require 'datagrammer/packet'
require 'datagrammer/packet_scanner'
require 'datagrammer/generic_handler'

# A Datagrammer object will listen on a given address and port for messages and
# will decode the data (it's assumed to be in a OSC-style format) and perform
# a callback when data is received:
#
#   dg = Datagrammer.new(5000)
#   dg.listen {|d, message, sender| d.speak %|rec'd "#{message.join(', ')}" at #{Time.now.to_s} from #{sender}|}
#   dg.thread.join
#   # now, anything sent to port 5000 on 0.0.0.0 that conforms to a basic
#   # OSC-style packet (f.e. from Max/MSP's udpsender) will be echoed back on port
#   # 5001 in the string format given in the block.
class Datagrammer
  
  # creates a new Datagrammer object bound to the specified port. The following
  # options are available:
  # * (({:address})): IP to listen on. defaults to "0.0.0.0"
  # * (({:speak_address})): default IP to send to. defaults to "0.0.0.0"
  # * (({:speak_port})): default port to speak on, defaults to port + 1
  def initialize(port, opts={})
    @port          = port
    @address       = opts[:address] || "0.0.0.0"
    @speak_address = opts[:speak_address] || "0.0.0.0"
    @speak_port    = opts[:speak_port] || port + 1
    @socket        = UDPSocket.new
    @socket.bind(@address, @port)
  end
  
  def speak_destination=(addr, port)
    @speak_address, @speak_port = addr, port
  end
  
  attr_accessor :thread, :socket, :speak_address, :speak_port
  
  def listen(&block)
    @thread = Thread.start do
      loop do
        IO.select([@socket])
        data, info = @socket.recvfrom(65535)
        block.call(self, Packet.decode(data), info.last)
      end
    end
  end
  
  def speak(message, addr=@speak_address, port=@speak_port)
    @socket.send(Packet.encode([message]), 0, addr, port)
  end
  
end