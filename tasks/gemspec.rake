require "rake/gempackagetask"
spec = Gem::Specification.new do |s|
  s.name         = 'datagrammer'
  s.version      = '0.2'
  s.summary      = "UDP without the pain"
  s.description  = "Sends and receives UDP packets in an OSC-compatable encoded format."

  s.author       = "Matthew Lyon"
  s.email        = "matt@flowerpowered.com"
  s.homepage     = "http://github.com/mattly/datagrammer"
  
  # code
  s.require_path = "lib"
  s.files        = %w( README.mkdn Rakefile ) + Dir["{spec,lib}/**/*"]
 
  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = ['README.mkdn']
  
 
  # Requirements
  s.required_ruby_version = ">= 1.8.6"
  
  s.platform = Gem::Platform::RUBY
end

desc "create .gemspec file (useful for github)"
task :gemspec do
  filename = "#{spec.name}.gemspec"
  File.open(filename, "w") do |f|
    f.puts spec.to_ruby
  end
end