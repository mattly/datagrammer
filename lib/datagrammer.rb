require 'socket'

$:.unshift File.dirname(__FILE__)
require 'datagrammer/packet'
require 'datagrammer/packet_scanner'

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
  attr_accessor :thread, :socket, :speak_address, :speak_port, :string_rules, :regex_rules
  
  # Creates a new Datagrammer object bound to the specified port. The following
  # options are available:
  # * (({:address})): IP to listen on. defaults to "0.0.0.0"
  # * (({:speak_address})): default IP to send to. defaults to "0.0.0.0"
  # * (({:speak_port})): default port to speak on, defaults to port + 1
  # * (({:rules})): a hash of key, proc pairs that will become the initial ruleset for figuring out what to do with
  #   received data. See '#register_rule' for more information
  # * (({:listen})): boolean, default true, to start listening on instantiation
  #
  # Your datagrammer instance will start listening automatically unless otherwise directed by :listen
  def initialize(port, opts={})
    @port          = port
    @address       = opts[:address] || "0.0.0.0"
    @speak_address = opts[:speak_address] || @address
    @speak_port    = opts[:speak_port] || port + 1
    @string_rules, @regex_rules = {}, {}
    @default_rule  = nil
    (opts[:rules]||{}).each_pair {|key, value| register_rule(key, value) }
    @socket        = UDPSocket.new
    @socket.bind(@address, @port)
    listen unless opts.has_key?(:listen) && ! opts[:listen]
  end
  
  # Defines a rule to match and a process to run if matched. Rule keys are matched
  # against the first item in the "data" value passed in from Datagrammer, or the
  # so-called "path" of the message. Data like (({['/foo/bar', 'baz', 'bee']})) would
  # use "/foo/bar" as the path to match against.
  #
  # Rules are evaluated in this order:
  # * If a rule key is a string and it matches the path exactly, that rule will be used.
  # * If no string rule keys match, any rule keys that are regexes will be run against the 
  #   path and ALL regexes that match will be called. The match(es) from the regex will be
  #   prepended to the argument list passed to the proc.
  # * If there is no match yet and a rule key called '\default' exists, that rule will be used.
  # * If no match has been made at this point, nothing will happen, the data will be ignored.
  def register_rule(rule, block)
    @string_rules[rule] = block if rule.kind_of?(String)
    @regex_rules[rule]  = block if rule.kind_of?(Regexp)
    @default_rule       = block if rule == :default
  end
  
  # runs the first part of the incoming message against the registered rules.
  def handle(address, arguments=[])
    list = []
    list << [@string_rules[address], arguments]
    list += @regex_rules.select {|key, value| address =~ key }.map do |regex, action|
      msg = [address.scan(regex), arguments].flatten
      msg.delete('')
      [action, msg]
    end
    list.delete_if {|callback, args| callback.nil? }
    list << [@default_rule, arguments] if list.empty? && @default_rule
    list.map {|callback, args| callback.call(args) }
  end
  
  
  # Sets the default speak destination
  def speak_destination=(addr, port)
    @speak_address, @speak_port = addr, port
  end
  
  # Starts the thread to listen on the selected port.
  def listen
    @thread = Thread.start do
      loop do
        IO.select([@socket])
        data, info = @socket.recvfrom(65535)
        data = Packet.decode(data)
        handle(data.shift, data)
        # block.call(self, Packet.decode(data), info.last)
      end
    end
  end
  
  # Encodes and sends a packet to the specified address and port
  def speak(message, addr=@speak_address, port=@speak_port)
    @socket.send(Packet.encode([message]), 0, addr, port)
  end
  
  private
  
end