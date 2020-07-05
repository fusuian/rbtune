# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rbtune/version"

Gem::Specification.new do |spec|
  spec.name          = "rbtune"
  spec.version       = Rbtune::VERSION
  spec.authors       = ["ASAHI,Michiharu"]
  spec.email         = ["fusuian@gmail.com"]

  spec.summary       = %q{The Japanese IP simulcast Player and Recorder.}
  spec.description   = %q{Playing and Recording Radiko, Radiru*Radiru and the other IP simulcast sites.}
  spec.homepage      = "https://github.com/fusuian/rbtune"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new("~> 2.5")


  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables = %w(rbtune timefree)
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize", "~> 2.7"
  spec.add_dependency "rmagick", "= 2.13.2" # swf_ruby が依存するので固定
  spec.add_dependency "swf_ruby", "~> 0.2"
  spec.add_dependency "pit", "~> 0.0.7"
  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", ">= 12.3.3"

end
