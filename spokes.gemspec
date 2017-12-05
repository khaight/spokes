$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'spokes/version'

Gem::Specification.new do |gem|
  gem.name    = 'spokes'
  gem.version = Spokes::VERSION

  gem.authors     = ['Brett Buddin', 'Kevin Haight']
  gem.email       = ['kevinjhaight@gmail.com']
  gem.homepage    = 'https://github.com/khaight/spokes'
  gem.summary     = 'A set of utilities for helping creating apis'
  gem.description = 'Setting up configuration of environment variables, versioning, & other middleware should be easier.  This is is a set of utilities to help.'
  gem.license = 'MIT'

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }

  gem.add_dependency 'activesupport', '~> 5.1', '>= 5.1.0'
  gem.add_dependency 'multi_json', '~> 1.12', '>= 1.12.1'

  gem.add_development_dependency 'factory_bot', '~> 4.8'
  gem.add_development_dependency 'rack-test', '~> 0.6', '>= 0.6.2'
  gem.add_development_dependency 'rake', '~> 0.8', '>= 0.8.7'
  gem.add_development_dependency 'rspec', '~> 3.1', '>= 3.1.0'
  gem.add_development_dependency 'rspec-rails', '~> 3.6', '>= 3.6.0'
  gem.add_development_dependency 'rubocop', '~> 0.48.1'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2.4'
  gem.add_development_dependency 'simplecov', '~> 0.14.1'
end
