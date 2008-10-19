require 'strscan'

class Datagrammer
  module Packet
    
    def self.decode(packet_string='')
      scanner = StringScanner.new(packet_string)
      message = scanner.scan_string
      argument_types = scanner.scan_string.sub(/^,/,'').split('')
      arguments = argument_types.inject([]) do |memo, type|
        case type
        when 's'; memo << scanner.scan_string
        when 'i'; memo << scanner.scan_integer
        when 'f'; memo << scanner.scan_float
        end
        memo
      end
      [message, arguments]
    end
    
    def self.encode(message=[])
      message = [message].flatten
      string = pad(message.shift)
      string += encode_arguments(message)
    end
    
    def self.pad(string='')
      string += "\000"
      string + "\000" * ((4-string.size) % 4)
    end
    
    protected
    
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
