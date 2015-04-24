# encoding: utf-8

require 'active_support/core_ext/hash/indifferent_access'

def ControllerMock(*mods)
  mods.inject(Class.new(ControllerMock)) do |c, mod|
    c.send(:include, mod)
  end
end

class ControllerMock
  attr_accessor :params, :request, :current_user
  def self.before_filter(*); end

  def initialize(params = {}, headers = {})
    self.params = params.with_indifferent_access
    self.request = OpenStruct.new(headers: headers.with_indifferent_access)
  end
end
