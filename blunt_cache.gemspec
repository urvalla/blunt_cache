# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blunt_cache/version'

Gem::Specification.new do |spec|
  spec.name          = "blunt-cache"
  spec.version       = BluntCache::VERSION
  spec.authors       = ["Roman Exempliarov"]
  spec.email         = ["urvala@gmail.com"]
  spec.summary       = %q{Simple in-memory cache service for ruby.}
  spec.description   = %q{Simple in-memory cache service for ruby.}
  spec.homepage      = "https://github.com/appelsin/blunt_cache"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
end