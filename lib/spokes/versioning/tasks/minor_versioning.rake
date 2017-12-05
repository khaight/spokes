# encoding: utf-8

namespace :spokes do
  namespace :versioning do
    MINOR_VERSION_YML = File.join(File.dirname(__FILE__), '../config/minor_versions.yml').to_s.freeze

    desc 'Sets up minor versioning yml'
    task setup: :environment do
      raise 'Minor version currently only supports Rails Applications' unless defined?(Rails)
      next if File.exist?("#{Rails.root}/config/minor_versions.yml")
      FileUtils.cp(MINOR_VERSION_YML, "#{Rails.root}/config", verbose: true)
    end
  end
end
