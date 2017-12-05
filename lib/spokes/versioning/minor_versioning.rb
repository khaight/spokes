require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext'
require_relative 'railtie' if defined?(Rails)

module Spokes
  module Versioning
    # Minor versioning mix-in for controllers.
    #
    # Usage:
    #
    #   # app/controllers/my_controller.rb
    #   class MyController
    #     include MinorVersioning
    #
    #     def index
    #       logger.info(minor_version)
    #     end
    #   end
    #
    module MinorVersioning
      extend ActiveSupport::Concern

      API_VERSION = 'API-Version'.freeze

      included do
        include MinorVersioning
        after_filter :set_minor_version_response_header
      end

      def set_minor_version_response_header
        response.headers[API_VERSION] = minor_version
      end

      def minor_version
        @minor_version ||= begin
                             chosen_version = request.headers[API_VERSION]
                             return chosen_version if valid_minor_version?(chosen_version)
                             default_minor_version
                           end
      end

      private

      def default_minor_version
        @default_minor_version ||= begin
                                     default = find_default_version
                                     raise('No version marked as default in the configuration.') if default.nil?
                                     default
                                   end
      end

      def find_default_version
        all_minor_versions.each do |version, info|
          return version if info[:default]
        end
        nil
      end

      def valid_minor_version?(version)
        version.present? && all_minor_versions.keys.include?(version)
      end

      def all_minor_versions
        has_versions = Rails.application.config.respond_to?(:minor_versions)
        raise('config/minor_versions.yml doesn\'t exist.') unless has_versions
        Rails.application.config.minor_versions
      end
    end
  end
end
