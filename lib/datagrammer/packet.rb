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
      argtypes = []
      lead = message.shift
      arguments = message.inject("") do |packet, argument|
        packet << if argument.kind_of?(String)
          pad(argument)
        elsif argument.kind_of?(Integer)
          [argument].pack('N')
        elsif argument.kind_of?(Float)
          [argument].pack('g')
        end
      end
    end
    
    def self.pad(string='')
      string += "\000"
      string + "\000" * ((4-string.size) % 4)
    end
    
  end
end
