require File.dirname(__FILE__) + '/spec_helper.rb'

describe Datagrammer::Packet do
  describe "decode" do
    it "handles a message with no arguments" do
      Datagrammer::Packet.decode("hello\000\000\000,\000\000\000").should == ['hello']
    end
    
    it "handles a generic message with many arguments" do
      encoded = "message\000,sifii\000\000str1\000\000\000\000\000\000\000\001@I\016V\177\377\377\377\377\377\377\366"
      msg = Datagrammer::Packet.decode(encoded)
      msg.shift.should == 'message'
      msg.shift.should == 'str1'
      msg.shift.should == 1
      (msg.shift * 10000).round.should == 31415
      msg.shift.should == 2147483647
      msg.shift.should == -10
    end
    
    it "handes a message with only integer arguments" do
      encoded = "/tick\000\000\000,iiii\000\000\000\000\000\000\252\000\000\000\002\000\000\001\245\000\004\367\006"
      Datagrammer::Packet.decode(encoded).should == ['/tick', 170, 2, 421, 325382]
    end
    
    it "handles encoded newlines correctly" do
      encoded = "tick\n\000\000\000,ii\000\000\000\000\n\000\000\334\n"
      Datagrammer::Packet.decode(encoded).should == ["tick\n", 10, 56330]
    end
    
    it "handles encoded booleans correctly" do
      encoded = "boolean\000,TF\000"
      Datagrammer::Packet.decode(encoded).should == ["boolean", true, false]
    end
    
    it "handles encoded nils correctly" do
      encoded = "nil\000,N\000\000"
      Datagrammer::Packet.decode(encoded).should == ["nil", nil]
    end
  end
  
  describe "encode" do
    [ [['hello'], "hello\000\000\000,\000\000\000"],
      [['hello','world'], "hello\000\000\000,s\000\000world\000\000\000"],
      [['hello', true, false, nil], "hello\000\000\000,TFN\000\000\000\000"],
      [['hello', 'world', 1, 2.0], "hello\000\000\000,sif\000\000\000\000world\000\000\000\000\000\000\001@\000\000\000"]
    ].each do |message, expected|
      describe "message: #{message.join(', ')}" do
        it "properly formats" do
          Datagrammer::Packet.encode(message).should == expected
        end
      end
    end
  end
  
end