require File.dirname(__FILE__) + '/spec_helper.rb'

describe Datagrammer::Packet do
  describe "decode" do
    it "handles a message with no arguments" do
      Datagrammer::Packet.decode("hello\000\000\000,\000\000\000").should == ['hello', []]
    end
    
    it "handles a generic message with many arguments" do
      encoded = "message\000,sifii\000\000str1\000\000\000\000\000\000\000\001@I\016V\177\377\377\377\377\377\377\366"
      msg, args = Datagrammer::Packet.decode(encoded)
      msg.should == 'message'
      args.shift.should == 'str1'
      args.shift.should == 1
      (args.shift * 10000).round.should == 31415
      args.shift.should == 2147483647
      args.shift.should == -10
    end
    
    it "handes a message with only integer arguments" do
      encoded = "/tick\000\000\000,iiii\000\000\000\000\000\000\252\000\000\000\002\000\000\001\245\000\004\367\006"
      Datagrammer::Packet.decode(encoded).should == ['/tick', [170, 2, 421, 325382]]
    end
    
    it "handles encoded newlines correctly" do
      encoded = "tick\n\000\000\000,ii\000\000\000\000\n\000\000\334\n"
      Datagrammer::Packet.decode(encoded).should == ["tick\n", [10, 56330]]
    end
  end
  
  describe "encode" do
    [ [['hello'], "hello\000\000\000,\000\000\000"],
      [['hello','world'], "hello\000\000\000,s\000\000world\000\000\000"],
      [['hello', 'world', 1, 2.0], "hello\000\000\000,sif\000\000\000\000world\000\000\000\000\000\000\001@\000\000\000"]
    ].each do |message, expected|
      describe "message: #{message.join(', ')}" do
        it "properly formats" do
          Datagrammer::Packet.encode(message).should == expected
        end
      end
    end
  end
  
  describe "pad" do
    it "fills out to the nearest word length" do
      Datagrammer::Packet.pad("h").should == "h\000\000\000"
    end
    
    it "appends nulls if string is already at wordlength" do
      Datagrammer::Packet.pad("word").should == "word\000\000\000\000"
    end
  end
end