module Spokes
  module Middleware
    # Provides `/status` route.
    #
    # Example setup:
    #
    #   class Application < Rails::Application
    #     config.middleware.use Spokes::Middleware::Health
    #   end
    #
    # Example responses:
    #
    #   $ curl -v -L http://localhost:3000/status
    #   > GET /status HTTP/1.1
    #   > User-Agent: curl/7.37.1
    #   > Host: localhost:3000
    #   > Accept: */*
    #   >
    #   < HTTP/1.1 200 OK
    #   < Content-Type: text/plain
    #   < Cache-Control: must-revalidate,no-cache,no-store
    #   < X-Request-Id: 8916fc91-b773-4002-9a9a-59870894715c
    #   < X-Runtime: 0.001055
    #   < Transfer-Encoding: chunked
    #   <
    #   OK
    #
    #   $ curl -v -L http://localhost:3000/status -H "Content-Type: application/json"
    #   > GET /status HTTP/1.1
    #   > User-Agent: curl/7.37.1
    #   > Host: localhost:3000
    #   > Accept: */*
    #   > Content-Type: application/json
    #   >
    #   < HTTP/1.1 200 OK
    #   < Content-Type: application/json
    #   < Cache-Control: must-revalidate,no-cache,no-store
    #   < X-Request-Id: 0a598c48-ca37-4b61-9677-20d8a8a4d637
    #   < X-Runtime: 0.001252
    #   < Transfer-Encoding: chunked
    #   <
    #   {"status":"OK"}
    #
    class Health
      PATH = '/status'.freeze

      def initialize(app, options = {})
        @app = app
        @options = {
          content_type: { simple: 'text/plain', details: 'application/json' },
          fail_if: -> { false },
          simple: ->(healthy) { healthy ? 'OK' : 'FAIL' },
          details: ->(healthy) { healthy ? { 'status': 'OK' }.to_json : { 'status': 'FAIL' }.to_json },
          status_code: ->(healthy) { healthy ? 200 : 503 },
          headers: lambda do |content_type|
            { 'Content-Type' => content_type, 'Cache-Control' => 'must-revalidate,no-cache,no-store' }
          end
        }.merge(options)
      end

      def call(env)
        return @app.call(env) unless env['REQUEST_METHOD'] == 'GET' && env['PATH_INFO'] == PATH
        healthy = !@options[:fail_if].call
        status = get_status(env, healthy)
        [status[:status], status[:headers], status[:body]]
      end

      private

      def get_status(env, healthy)
        d = env['CONTENT_TYPE'] == @options[:content_type][:details]
        body = [@options[(d ? :details : :simple)].call(healthy)]
        status = @options[:status_code].call(healthy)
        headers = @options[:headers].call(d ? @options[:content_type][:details] : @options[:content_type][:simple])
        { body: body, status: status, headers: headers }
      end
    end
  end
end
