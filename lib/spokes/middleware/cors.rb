module Spokes
  module Middleware
    # Provides CORS HTTP access control.
    #
    # Usage:
    #
    #   class Application < Rails::Application
    #     config.middleware.use Spokes::Middleware::CORS
    #   end
    #
    # Example response:
    #
    #   $ curl -v -L http://localhost:3000/ -H "Origin: http://elsewhere" -X OPTIONS
    #   > OPTIONS / HTTP/1.1
    #   > User-Agent: curl/7.37.1
    #   > Host: localhost:3000
    #   > Accept: */*
    #   > Origin: http://elsewhere
    #   >
    #   < HTTP/1.1 200 OK
    #   < Access-Control-Allow-Origin: http://elsewhere
    #   < Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
    #   < Access-Control-Allow-Headers: *, Content-Type, Accept, AUTHORIZATION, Cache-Control
    #   < Access-Control-Allow-Credentials: true
    #   < Access-Control-Max-Age: 1728000
    #   < Access-Control-Expose-Headers: Cache-Control, Content-Language, Content-Type, Expires, Last-Modified, Pragma
    #   < Cache-Control: no-cache
    #   < X-Request-Id: 1d388184-5dd6-4150-bf47-1729f33794ec
    #   < X-Runtime: 0.001269
    #   < Transfer-Encoding: chunked
    #
    class CORS
      ALLOW_METHODS  =
        %w[GET POST PUT PATCH DELETE OPTIONS].freeze
      ALLOW_HEADERS  =
        %w[* Content-Type Accept AUTHORIZATION Cache-Control].freeze
      EXPOSE_HEADERS =
        %w[Cache-Control Content-Language Content-Type Expires Last-Modified Pragma].freeze

      def initialize(app)
        @app = app
      end

      def call(env)
        # preflight request: render a stub 200 with the CORS headers
        if cors_request?(env) && env['REQUEST_METHOD'] == 'OPTIONS'
          [200, cors_headers(env), ['']]
        else
          status, headers, response = @app.call(env)
          headers.merge!(cors_headers(env)) if cors_request?(env)
          [status, headers, response]
        end
      end

      def cors_request?(env)
        env.key?('HTTP_ORIGIN')
      end

      def cors_headers(env)
        {
          'Access-Control-Allow-Origin'      => env['HTTP_ORIGIN'],
          'Access-Control-Allow-Methods'     => ALLOW_METHODS.join(', '),
          'Access-Control-Allow-Headers'     => ALLOW_HEADERS.join(', '),
          'Access-Control-Allow-Credentials' => 'true',
          'Access-Control-Max-Age'           => '1728000',
          'Access-Control-Expose-Headers'    => EXPOSE_HEADERS.join(', ')
        }
      end
    end
  end
end
