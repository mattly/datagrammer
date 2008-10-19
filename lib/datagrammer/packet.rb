require 'strscan'

class Datagrammer
  module Packet
    
    def self.decode(message='')
      scanner = StringScanner.new(message)
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
    
    def self.encode
      
    end
    
  end
end
