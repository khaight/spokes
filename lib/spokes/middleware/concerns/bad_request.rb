require 'multi_json'

module Spokes
  module Middleware
    module Concerns
      module BadRequest
        def bad_request(errors)
          errors = [errors] unless errors.is_a?(Array)
          [400, bad_request_headers, [bad_request_body(errors)]]
        end

        def bad_request_headers
          { 'Content-Type' => 'application/json; charset=utf-8' }
        end

        def bad_request_body(errors)
          MultiJson.dump(errors: errors)
        end
      end
    end
  end
end
