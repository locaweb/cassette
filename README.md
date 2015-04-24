# Cassette::Client

Library to generate and validate STs and TGTs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cassette'
```

And then execute:

```shell
$ bundle
```

## Usage

Require this library and create an intializer to set its configuration:

```ruby
Cassette.config = config
```

where config is an object that responds to the methods `base` for the base CAS uri, `username` and `password` if you are authenticating on other systems and `service` and `base_authority` if you are using the authentication filter to authenticate your app.

You may also set the caching backend using the .backend= module method:

```ruby
Cassette::Cache.backend = ActiveSupport::Cache::MemcacheStorage.new
```

By default, `Cassette::Cache` will check if you have `Rails.cache` defined or instantiate a new `ActiveSupport::Cache::MemoryStore`

To authenticate your Rails app, add to your `ApplicationController` (or any authenticated controller):

```ruby
class ApplicationController < ActionController::Base
  include Cassette::Authentication::Filter

  # ...
end
```

You should also rescue from `Cassette::Errors::Forbidden` with more friendly errors

If you wish to have actions that skip the authentication filter, add to your controller:

```ruby
class SomeController < ApplicationController
    skip_authentication # [*options]

    # skip_authentication only: "index"
end
```

Where options are the same options you can pass to Rails' `skip_before_filter` method

### Overriding the authenticated service

You can the service being authenticated in a controller (or group of controllers). To do this, override the instance method `authentication_service`:

```ruby
class ApiController < ApplicationController
  def authentication_service
    "api.#{super}"

    # or maybe a hardcoded:
    # "api.example.org"

    # looking like regular RubyCAS, using the url
    # request.url
  end
end
```

### Accepting multiple services (restricting from a list)

Your config object must respond to `services` and the filter will check your controller `authentication_service` against the list or the configured service.

In your initializer:

```ruby
Cassete.config = OpenStruct.new(
  # omitted
  service: "example.org",
  services: ["api.example.org", "www.example.org", "subdomain.example.org"]
)
```

And in your controller:

```ruby
class ApplicationController < ActionController::Base
  def authentication_service
    request.host
  end
end
```

In this example, only tickets generated for __api.example.org__, __www.example.org__, __subdomain.example.org__ or __example.org__ will be accepted others will raise a `Cassette::Errors::Forbidden`.

### Accepting multiple services (customized)

If whitelisting services is not enough for your application, you can override the `accepts_authentication_service?` in your controller.
This method receives the service and returns a boolean if the service is ok or not.

```ruby
class ApplicationController < ActionController::Base
  def accepts_authentication_service?(service)
    service.ends_with?('my-domain.com')
  end

  def authentication_service
    request.host
  end
end
```

## RubyCAS client helpers


If you are authenticating users with RubyCAS and want role checking, in your rubycas initializer:

```ruby
require "cas/rubycas"
```

And in your `ApplicationController` (or any authenticated controller):

```ruby
class SomeController < ApplicationController
    include Cassette::Rubycas::Helper

    # - Allow only employees:
    #
    # before_filter :employee_only_filter
    #
    # rescue_from Cassette::Errors::NotAnEmployee do
    #   redirect_to '/403.html'
    # end

    # - Allow only customers:
    #
    # before_filter :customer_only_filter
    #
    # rescue_from Cassette::Errors::NotACustomer do
    #   redirect_to '/403.html'
    # end
end
```

## Instantiating Cassette::Client and Cassette::Authentication

You can create your own instances of `Cassette::Client` (st/tgt generator) and `Cassette::Authentication` (st validator).

The constructor accepts a hash with keys (as symbols) for the values of cache, logger, http_client and configuration.

All values default to the same values used when accessing the class methods directly.

Please check the constructors or integration specs for details.

## About caching and tests

It is a good idea to always clear the cache between tests, specially if you're
using VCR. You can do it by using the invoking the `#clear` method of the cache
backend in use. The following excerpt will clear the cache of the default client
`Cassette::Client` instance:

```
Cassette::Client.cache.backend.clear
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
