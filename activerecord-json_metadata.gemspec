# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/json_metadata/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-json_metadata"
  spec.version       = Activerecord::JsonMetadata::VERSION
  spec.authors       = ["Sava Chankov"]
  spec.email         = ["sava@tutuf.com"]
  spec.description   = %q{Store table metadata as JSON in database in comments for columns}
  spec.summary       = %q{Store table metadata as JSON in database}
  spec.homepage      = "http://github.com/tutuf/activerecord-json_metadata"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~>3.0.3"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
