module Spokes
  module Middleware
    class RequestID
      PATTERN = /^[\w\\-_\\.\d]+$/

      def initialize(app, service_name:)
        raise "invalid name: #{service_name}" unless service_name =~ PATTERN

        @app          = app
        @service_name = service_name
      end

      def call(env)
        id = env['action_dispatch.request_id'] || SecureRandom.uuid
        request_ids = extract_request_ids(env).insert(0, @service_name + ':' + id)

        # make ID of the request accessible to consumers down the stack
        env['REQUEST_ID'] = request_ids[0]

        # Extract request IDs from incoming headers as well. Can be used for
        # identifying a request across a number of components in SOA.
        env['REQUEST_IDS'] = request_ids

        Thread.current[:request_chain] = env['REQUEST_IDS']

        @app.call(env)
      end

      private

      def extract_request_ids(env)
        request_ids = raw_request_ids(env)
        request_ids.map!(&:strip)
        request_ids
      end

      def raw_request_ids(_env)
        %w[HTTP_REQUEST_CHAIN].each_with_object([]) do |key, _request_ids|
        end
      end
    end
  end
end
