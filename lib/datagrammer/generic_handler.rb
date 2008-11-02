class Datagrammer
  # A simple class for registering multiple "handlers" for messages that come from a Datagrammer object.
  class GenericHandler
    attr_accessor :rules
    
    # Takes a hash of key, proc values for an initial set of rules. Rule keys are matched
    # against the first item in the "data" value passed in from Datagrammer, or the
    # so-called "path" of the message. Data like (({['/foo/bar', 'baz', 'bee']})) would
    # use "/foo/bar" as the path to match against.
    #
    # Rules are evaluated in this order:
    # * If a rule key is a string and it matches the path exactly, that rule will be used.
    # * If no string rule keys match, any rule keys that are regexes will be run against the 
    #   path and ALL regexes that match will be called. The match(es) from the regex will be
    #   prepended to the argument list passed to the proc.
    # * If there is no match yet and a rule key called '\default' exists, that rule will be used.
    # * If no match has been made at this point, nothing will happen, the data will be ignored.
    def initialize(rules={})
      @rules = rules
    end
    
    # sets a proc to be called when a rule is matched. See #new for more information.
    def register_rule(address, block)
      @rules[address] = block
    end
    
    # What Datagrammer calls. Runs the path against registered rules as described in #new
    def handle(address, arguments=[])
      list = if @rules.has_key?(address)
        [[@rules[address], arguments]]
      else
        matches = @rules.select {|k,v| k.kind_of?(Regexp) && address =~ k }
        if ! matches.empty?
          matches.collect do |regex, p| 
            msg = [address.scan(regex), arguments].flatten
            msg.delete('')
            [p, msg]
          end
        elsif @rules.has_key?('\default')
          [[@rules['\default'], arguments]]
        else
          []
        end
      end
      list.map {|callback, args| callback.call(args) }
    end
    
    # returns a lambda for a Datagrammer object's listen method
    def handler
      lambda {|dg, args, sender| self.handle(args.shift, args) }
    end
    
  end
end