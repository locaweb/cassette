# Cassette::Client

Library to generate and validate STs and TGTs

## Installation

Add this line to your application's Gemfile:

    gem 'cassette'

And then execute:

    $ bundle

## Usage

Require this library and create an intializer to set its configuration:


    Cassette.config = config


where config is an object that responds to the methods #base for the base CAS uri, #username and #password
if you are authenticating on other systems and #service and #base\_authority if you are using the authentication filter
to authenticate your app


You may also set the caching backend using the .backend= module method:


    Cassette::Cache.backend = ActiveSupport::Cache::MemcacheStorage.new


By default, Cassette::Cache will check if you have Rails.cache defined or instantiate a new ActiveSupport::Cache::MemoryStore


To authenticate your Rails app, add to your ApplicationController (or any authenticated controller):


    class ApplicationController < ActionController::Base
      include Cassette::Authentication::Filter


      (...)

    end


You should also rescue from Cassette::Errors::Forbidden with more friendly errors

If you wish to have actions that skip the authentication filter, add to your controller:


    skip_authentication [options]


Where options are the same options you can pass to Rails' __skip_before_filter__ method

## RubyCAS client helpers


If you are authenticating users with RubyCAS and want role checking, in your rubycas initializer:


    require "cas/rubycas"


And in your ApplicationController (or any authenticated controller):


    include Cassette::Rubycas::Helper

    # - Allow only employees:
    #
    # before_filter :employee_only_filter
    #
    # rescue_from Cassette::Errors::NotAnEmployee d
    #   redirect_to '/403.html'
    # end

    # - Allow only customers:
    #
    # before_filter :customer_only_filter
    #
    # rescue_from Cassette::Errors::NotACustomer do
    #   redirect_to '/403.html'
    # end


## Instantiating Cassette::Client and Cassette::Authentication

You can create your own instances of __Cassette::Client__ (st/tgt generator) and __Cassette::Authentication__ (st validator).

The constructor accepts a hash with keys (as symbols) for the values of cache, logger, http_client and configuration.

All values default to the same values used when accessing the class methods directly.

Please check the constructors or integration specs for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
