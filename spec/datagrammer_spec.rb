require File.dirname(__FILE__) + '/spec_helper.rb'

describe Datagrammer do
  
  before do
    @serv = Datagrammer.new(10000)
  end
  
  after do
    @serv.socket.close
  end
  
  def setup_socket(port, addr="0.0.0.0")
    s = UDPSocket.new
    s.bind(addr, port)
    s
  end
  
  describe "sending messages" do
    it "should send an encoded packet out to its speaking port" do
      Thread.start { sleep 0.1; @serv.speak("hi") }
      sock = setup_socket(10001)
      IO.select [sock]
      data, info = sock.recvfrom(1024)
      sock.close
      data.should == "hi\000\000,\000\000\000"
    end
  end
  
  describe "handling received messages" do
    
    before do
      @bar = 'baz'
      @foo = lambda {|args| @bar = "foo: #{args.join(', ')}" }
      @serv.register_rule('foo', @foo)
    end
    
    it "should receive encoded packets while listening and feed it to the handler" do
      @serv.should_receive(:handle).with('foo', ['hi'])
      s = UDPSocket.new
      s.send("foo\000,s\000\000hi\000\000", 0, '0.0.0.0', 10000)
      sleep 0.1
    end
    
    it "calls the handler for a given address" do
      @serv.handle('foo', %w(bar baz)).should == ["foo: bar, baz"]
    end

    describe "with regex handlers" do
      before do
        @i = Hash.new {|hash, key| hash[key] = [] }
        @serv.register_rule(/^\/reg\/(.*)$/, lambda {|a| @i[a.shift] += a})
      end

      it "accepts regexes as hanlder keys and calls their values when matched" do
        @serv.handle('/reg/foo', %w(bar baz))
        @i.should == {'foo' => %w(bar baz)}
      end

      it "handles values for ALL regexes that match given string" do
        @serv.register_rule(/.*/, lambda {|a| @i['default'] += a })
        @serv.handle('/reg/foo', %w(bar baz))
        @i.should == {'foo' => %w(bar baz), 'default' => %w(/reg/foo bar baz)}
      end

      it "uses regexes if exact match from string" do
        @serv.register_rule('/reg/foo', lambda {|a| @i['exact'] += a })
        @serv.handle('/reg/foo', %w(bar baz))
        @i.should == {'exact' => %w(bar baz), 'foo' => %w(bar baz)}
      end
    end

    describe "with no handler found" do
      it "uses 'default' if exists" do
        @serv.register_rule(:default, lambda {@i = 'default'})
        @serv.handle('/non-existant')
        @i.should == 'default'
      end

      it "does nothing if no default handler" do
        @serv.handle('/non-existant').should == []
      end
    end
  end
  
end