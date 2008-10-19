require File.dirname(__FILE__) + '/spec_helper.rb'

describe StringScanner do
  
  describe "skip_buffer" do
    it "sets the position to the next multiple of four" do
      s = StringScanner.new('more than four bytes')
      [[4,8], [6,8], [1,4]].each do |pos, expected|
        s.pos = pos
        s.skip_buffer
        s.pos.should == expected
      end
    end
  end
  
  describe "scan_string" do
    
    before do
      @s = StringScanner.new("this is a string!\000\000\000end.")
      @string = @s.scan_string
    end
    
    it "extracts the string" do
      @string.should == "this is a string!"
    end
    
    it "sets the position to the next word" do
      @s.pos.should == 20
    end
  end
  
  describe "scan_integer" do
    [[1,"\000\000\000\001"], [-10, "\377\377\377\366"], [2147483647, "\177\377\377\377"]].each do |integer, encoded|
      describe "decdoing #{integer}" do
        before do
          @s = StringScanner.new(encoded)
          @int = @s.scan_integer
        end
        
        it "decodes the integer correctly" do
          @int.should == integer
        end
        
        it "sets the position at the end of the word" do
          @s.pos.should == 4
        end
      end
    end
  end
  
  describe "scan_float" do
    [[1.0, "?\200\000\000"], [3.141593, "@I\017\333"], [-1.618034, "\277\317\e\275"]].each do |float, encoded|
      describe "decoding #{float}" do
        before do
          @s = StringScanner.new(encoded)
          @float = @s.scan_float
        end
        
        it "decodes the float value correctly" do
          (@float * 100000).round.should == (float * 100000).round
        end
        
        it "sets the position to the end of the word" do
          @s.pos.should == 4
        end
      end
    end
  end
  
end