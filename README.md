
<img src="https://raw.githubusercontent.com/khaight/spokes/master/logo/spokes_logo.png" alt="Spokes Logo"/>

A set of utilities for helping creating apis

- [Configuration](#configuration)
- [Middleware](#middleware)
    - [Health](#health)
    - [CORS](#cors)
    - [Service Name](#service_name)
- [Versioning](#versioning)
    - [Minor Versioning](#minor-versioning)

## Configuration

Provides an easy to use set of configuration methods to manage environment variables.

Example:

```
# config/application.rb

Spokes::Config::Env.load do
  mandatory :homer, string
  default :krusty, :clown, symbol
  optional :duffman, boolean
end
```

The above example will look for the following environment variables when booting your application as well as try to perform type coercion:

```
ENV['HOMER'] # will raise KeyError if variable does not exist; will 'cast' value to a string if exists

ENV['KRUSTY'] # will try to 'cast' value to a symbol if exists; otherwise will populate with the default value :clown

ENV['DUFFMAN'] # will try to 'cast' value to a boolean if exists and will do nothing otherwise
```

## Middleware

### Health

Provides a `/status` endpoint on your API.

#### Installation

Add the following to your Rails project:

```ruby
# config/application.rb
class Application < Rails::Application
    config.middleware.use Spokes::Middleware::Health
end
```

#### Configuration Arguments

| name           |  description                                                                                                                            |
| -------------- |  -----------                                                                                                                            |
| `fail_if`      |  Mechanism for putting the service into a "failing" state                                                                               |
| `content_type` |  Establishes content types returned for the different representations of the health response. Requires two keys: `simple` and `details` |
| `details`      |  Override the body content returned in details view                                                                                     |
| `status_code`  |  Override the body content returned in simple view                                                                                      |
| `headers`      |  Override the headers in health responses. Takes `Content-Type` header value as a parameter.                                            |

### CORS

Provides CORS HTTP access control headers in all responses.

#### Installation

Add the following to your Rails project:

```ruby
# config/application.rb
class Application < Rails::Application
    config.middleware.use Spokes::Middleware::CORS
end
```


#### Installation

Add the following to your Rails project:

```ruby
# config/application.rb
class Application < Rails::Application
    config.middleware.use Spokes::Middleware::OrganizationId
end
```

### Service Name

Requires and validates `Service-Name` header in all requests. Appends the current service's name to all outbound
responses.

#### Installation

Add the following to your Rails project:

```ruby
# config/application.rb
class Application < Rails::Application
    config.middleware.use Spokes::Middleware::ServiceName
end
```

## Versioning

### Minor Versioning

Parses the `API-Version` HTTP header and makes it available in controllers via the `minor_version` helper method.
This concern also adds the `API-Version` header to all outgoing responses.

#### Installation

1. Add the following to your Rails project:

    ```ruby
    # app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base
        include Spokes::Versioning::MinorVersioning
    end
    ```
2. Execute the following in your Rails project's directory:

    ```bash
    $ bundle exec rake spokes:versioning:setup
    ```
3. You'll now have a file created at `config/minor_versions.yml`. Edit this file as needed to set up the default
   version for your API. Any subsequent versions will be listed there as well.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khaight/spokes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
