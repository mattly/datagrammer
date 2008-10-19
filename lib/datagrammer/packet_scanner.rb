class Datagrammer
  module PacketScanner
    
    def skip_buffer
      self.pos += 4 - (pos % 4)
    end
    
    def scan_string
      string = scan(/[^\000]+/)
      skip_buffer
      string
    end
    
    def scan_integer
      integer = scan(/.{4}/m).unpack('N').first
      integer = -1 * (2**32 - integer) if integer > (2**31 - 1)
      integer
    end
    
    def scan_float
      scan(/.{4}/).unpack('g').first
    end
    
  end
end

StringScanner.send(:include, Datagrammer::PacketScanner)