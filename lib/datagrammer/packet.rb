require 'strscan'

class Datagrammer
  
  # Decodes and Encodes packets into a basic OSC (Open Sound Control)-like format.
  module Packet
    
    # decodes packet data from f.e. (({"hello\000\000\000,s\000\000world\000\000\000"})) to 
    # (({%w(hello world)}))
    def self.decode(packet_string='')
      scanner = PacketScanner.new(packet_string)
      message = scanner.scan_string
      argument_types = scanner.scan_string.sub(/^,/,'').split('')
      arguments = argument_types.collect do |type|
        { 's' => lambda { scanner.scan_string },
          'i' => lambda { scanner.scan_integer },
          'f' => lambda { scanner.scan_float }
        }[type].call()
      end
      arguments.unshift(message)
    end
    
    # Turns a list or array into an encoded string
    def self.encode(*message)
      message = [message].flatten
      string = pad(message.shift)
      string += encode_arguments(message)
    end
    
  protected

    def self.pad(string='')
      string += "\000"
      string + "\000" * ((4-string.size) % 4)
    end
    
    def self.encode_arguments(arguments)
      encode_argument_types(arguments) + encode_argument_data(arguments)
    end
    
    def self.encode_argument_types(arguments)
      str = ','
      str += arguments.collect do |argument|
        case argument
        when String; 's' 
        when Integer; 'i'
        when Float; 'f'
        end
      end.join
      pad(str)
    end
    
    def self.encode_argument_data(arguments)
      arguments.collect do |argument|
        case argument
        when String; pad(argument)
        when Integer; [argument].pack('N')
        when Float; [argument].pack('g')
        end
      end.join
    end
  end
end
