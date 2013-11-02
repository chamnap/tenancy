# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tenancy/version'

Gem::Specification.new do |spec|
  spec.name          = "tenancy"
  spec.version       = Tenancy::VERSION
  spec.authors       = ["chamnap"]
  spec.email         = ["chamnapchhorn@gmail.com"]
  spec.description   = %q{A simple multi-tenancy with activerecord through scoping}
  spec.summary       = %q{A simple multi-tenancy with activerecord through scoping}
  spec.homepage      = "https://github.com/yoolk/tenancy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 2.12.0"
  spec.add_development_dependency "shoulda", "~> 3.5.0"
  spec.add_development_dependency "pry", "~> 0.9.12"
  spec.add_development_dependency "sqlite3", "~> 1.3.7"
  spec.add_development_dependency "rake"

  spec.add_dependency "activerecord", "~> 3.2.13"
end
