# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tenancy/version"

Gem::Specification.new do |spec|
  spec.name          = "tenancy"
  spec.version       = Tenancy::VERSION
  spec.authors       = ["Chamnap Chhorn"]
  spec.email         = ["chamnapchhorn@gmail.com"]
  spec.description   = %q{A simple multitenancy with activerecord/mongoid through scoping}
  spec.summary       = %q{A simple multitenancy with activerecord/mongoid through scoping}
  spec.homepage      = "https://github.com/yoolk/tenancy"
  spec.license       = "MIT"

  spec.required_ruby_version     = ">= 1.9.3"
  spec.required_rubygems_version = ">= 1.8.11"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.2"
  spec.add_dependency "request_store", "~> 1.0.5"
end