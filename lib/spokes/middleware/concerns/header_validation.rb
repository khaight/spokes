module Spokes
  module Middleware
    module Concerns
      module HeaderValidation
        class NotValid < StandardError; end

        def validate_header_presence(env:, header_name:, message: 'is required')
          value = env[env_header_name(header_name)]
          raise NotValid, "#{header_name} #{message}" if value.nil? || value.empty?
        end

        def validate_header_pattern(env:, header_name:, pattern:, message: 'is invalid')
          value = env[env_header_name(header_name)]
          raise NotValid, "#{header_name} #{message}" unless value =~ pattern
        end

        def env_header_name(name)
          "HTTP_#{name.upcase.tr('-', '_')}"
        end
      end
    end
  end
end
