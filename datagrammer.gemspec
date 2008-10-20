# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{datagrammer}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Lyon"]
  s.date = %q{2008-10-19}
  s.description = %q{Sends and receives UDP packets in an OSC-compatable encoded format.}
  s.email = %q{matt@flowerpowered.com}
  s.files = ["README.mkdn", "Rakefile", "spec/datagrammer_spec.rb", "spec/packet_scanner_spec.rb", "spec/packet_spec.rb", "spec/spec_helper.rb", "lib/datagrammer", "lib/datagrammer/packet.rb", "lib/datagrammer/packet_scanner.rb", "lib/datagrammer.rb"]
  s.homepage = %q{http://github.com/mattly/datagrammer}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{UDP without the pain}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
