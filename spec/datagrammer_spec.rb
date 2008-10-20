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
  
  it "should send an encoded packet out to its speaking port" do
    Thread.start { sleep 0.1; @serv.speak("hi") }
    sock = setup_socket(10001)
    IO.select [sock]
    data, info = sock.recvfrom(1024)
    sock.close
    data.should == "hi\000\000,\000\000\000"
  end
  
  it "should receive encoded packets while listening and feed it to the callback" do
    @serv.listen {|dg, msg| @foo = msg }
    s = UDPSocket.new
    s.send("hi\000\000,\000\000\000", 0, '0.0.0.0', 10000)
    sleep 0.1
    @foo.should == ['hi']
  end
  
end