module Spokes
  module Middleware
    # Validates inbound and sets outbound Service-Name HTTP headers.
    #
    # Usage:
    #
    #   class Application < Rails::Application
    #     config.middleware.use Spokes::Middleware::ServiceName
    #   end
    #
    class ServiceName
      include Middleware::Concerns::BadRequest
      include Middleware::Concerns::HeaderValidation

      PATTERN     = /^[\w\\-_\\.\d]+$/
      HEADER_NAME = 'Service-Name'.freeze

      def initialize(app, service_name:, exclude_paths: [])
        raise "invalid name: #{service_name}" unless service_name =~ PATTERN
        @app          = app
        @service_name = service_name
        @exclude_paths = path_to_regex(exclude_paths)
      end

      def call(env)
        begin
          unless exclude?(env['PATH_INFO'].chomp('/'))
            validate_header_presence(env: env, header_name: HEADER_NAME)
            validate_header_pattern(env: env, header_name: HEADER_NAME, pattern: PATTERN)
          end
        rescue Middleware::Concerns::HeaderValidation::NotValid => e
          return bad_request(e.message)
        end

        status, headers, body = @app.call(env)
        headers[HEADER_NAME] = @service_name
        [status, headers, body]
      end

      private

      def exclude?(path)
        @exclude_paths.each do |regex|
          return true if regex.match?(path)
        end
        false
      end

      # build out regular expression to match exclude path
      def path_to_regex(exclude_paths)
        reg_ex_path = []
        exclude_paths.each do |path|
          path_parts = path.split('/')
          regex_paths = path_parts.inject do |out, p|
            val = p
            val = '(\\S*)' if p.include?(':')
            out + '[/]' + val
          end
          reg_ex_path.push(Regexp.new(regex_paths))
        end
        reg_ex_path
      end
    end
  end
end
