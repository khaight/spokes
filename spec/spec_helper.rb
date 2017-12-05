ENV['RAILS_ENV'] = 'test'
$TEST = true

require 'bundler'
require 'simplecov'
require 'fileutils'
require 'rack/test'
require 'factory_bot'
require 'multi_json'

SimpleCov.start do
  add_filter '.gems'
  add_filter 'spec'
  add_group 'Middleware', ['/spokes/middleware/*']
  add_group 'Config', ['/spokes/config/*']
  add_group 'Versioning', ['/spokes/versioning/*']
end

require_relative '../lib/spokes'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods
  config.order = 'random'
end
