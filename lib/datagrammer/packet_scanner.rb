# Subclass of StringScanner to take the boring out of certain aspects of packet decoding.
class PacketScanner < StringScanner
  
  # Moves the scan head to the next multiple of 4
  def skip_buffer
    self.pos += 4 - (pos % 4)
  end
  
  # Grabs all non-null characters and moves the scan head past the null buffer
  def scan_string
    string = scan(/[^\000]+/)
    skip_buffer
    string
  end
  
  # Decodes an integer, adjusting for polarity
  def scan_integer
    integer = scan(/.{4}/m).unpack('N').first
    integer = -1 * (2**32 - integer) if integer > (2**31 - 1)
    integer
  end
  
  # Decodes a 32-bit float
  def scan_float
    scan(/.{4}/).unpack('g').first
  end
  
end
