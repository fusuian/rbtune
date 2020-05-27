# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rbtune/version"

Gem::Specification.new do |spec|
  spec.name          = "rbtune"
  spec.version       = Rbtune::VERSION
  spec.authors       = ["ASAHI,Michiharu"]
  spec.email         = ["fusuian@gmail.com"]

  spec.summary       = %q{The Japanese Netradio Player and Recorder.}
  spec.description   = %q{Playing and Recording Radiko, Radiru*Radiru, Radiko Premium, SimulRadio and ListenRadio.}
  spec.homepage      = "https://github.com/fusuian/rbtune"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables = %w(rbtune rbplay timefree)
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize", "~> 2.7"
  spec.add_dependency "rmagick", "= 2.13.2" # swf_ruby が依存するので固定
  spec.add_dependency "swf_ruby", "~> 0.2"
  spec.add_dependency "pit", "~> 0.0.7"
  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 10.0"
  # spec.add_development_dependency "pry"

end
