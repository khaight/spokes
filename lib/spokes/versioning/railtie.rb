# encoding: utf-8

require 'rails'

module Spokes
  class Railtie < Rails::Railtie
    initializer('spokes_versioning.load_minor_versions_file') do |app|
      config_file = Rails.root.join('config', 'minor_versions.yml')
      if File.exist?(config_file)
        minor_versions = YAML.load_file(config_file)
        app.config.minor_versions = {}
        minor_versions.map do |key, val|
          app.config.minor_versions[key] = val.symbolize_keys
        end
      end
    end

    rake_tasks do
      load 'spokes/versioning/tasks/minor_versioning.rake'
    end
  end
end
