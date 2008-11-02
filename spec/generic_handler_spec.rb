require File.dirname(__FILE__) + '/spec_helper.rb'

describe Datagrammer::GenericHandler do
  
  before do
    @handler = Datagrammer::GenericHandler.new
    @foo = lambda {|args| "foo: #{args.join(', ')}" }
    @handler.register_rule('/foo', @foo)
  end
  
  it "registers handlers" do
    @handler.rules['/foo'].should == @foo
  end
  
  it "calls the handler for a given address" do
    @handler.handle('/foo', %w(bar baz)).should == ["foo: bar, baz"]
  end
  
  it "spits out a lambda for calling the handler from DG" do
    @handler.should_receive(:handle).with('/foo',%w(bar baz))
    @handler.handler.call(nil, %w(/foo bar baz), nil)
  end
  
  describe "regex handlers" do
    before do
      @i = Hash.new {|hash, key| hash[key] = [] }
      @handler.register_rule(/^\/reg\/(.*)$/, lambda {|a| @i[a.shift] += a})
    end

    it "accepts regexes as hanlder keys and calls their values when matched" do
      @handler.handle('/reg/foo', %w(bar baz))
      @i.should == {'foo' => %w(bar baz)}
    end
    
    it "handles values for ALL regexes that match given string" do
      @handler.register_rule(/.*/, lambda {|a| @i['default'] += a })
      @handler.handle('/reg/foo', %w(bar baz))
      @i.should == {'foo' => %w(bar baz), 'default' => %w(/reg/foo bar baz)}
    end
    
    it "does not use regexes if exact match from string" do
      @handler.register_rule('/reg/foo', lambda {|a| @i['exact'] += a })
      @handler.handle('/reg/foo', %w(bar baz))
      @i.should == {'exact' => %w(bar baz)}
    end
  end
  
  describe "no handler found" do
    it "uses 'default' if exists" do
      default = lambda { 'default' }
      @handler.register_rule('\default', default)
      @handler.handle('/non-existant').should == ['default']
    end
  
    it "does nothing if no default handler" do
      @handler.handle('/non-existant').should == []
    end
  end
  
end