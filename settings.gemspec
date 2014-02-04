# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'settings/version'

Gem::Specification.new do |spec|
  spec.name          = 'settings'
  spec.version       = Settings::VERSION
  spec.authors       = ['Vsevolod Romashov']
  spec.email         = ['7@7vn.ru']
  spec.description   = 'Hashie::Mash-like settings'
  spec.summary       = 'Hashie::Mash-like settings loaded from YAML files.'
  spec.homepage      = 'https://github.com/roomink/settings'
  spec.license       = 'MIT'
  
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  
  spec.add_runtime_dependency 'hashie'
  spec.add_runtime_dependency 'activesupport'
  
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
