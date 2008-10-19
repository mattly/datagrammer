require 'rubygems'

begin
  require 'spec'
rescue LoadError
  gem 'rspec'
  require 'spec'
end

gem 'ruby-debug'
require 'ruby-debug'

require "#{File.dirname(__FILE__)}/../lib/datagrammer"

Debugger.start