require_relative 'spokes/middleware/concerns/bad_request.rb'
require_relative 'spokes/middleware/concerns/header_validation.rb'

require_relative 'spokes/middleware/cors.rb'
require_relative 'spokes/middleware/health.rb'
require_relative 'spokes/middleware/service_name.rb'
require_relative 'spokes/middleware/request_id.rb'

require_relative 'spokes/config/env.rb'
require_relative 'spokes/versioning/minor_versioning.rb'

module Spokes
end
