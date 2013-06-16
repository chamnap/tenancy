require "tenancy/version"
require "active_support/concern"

module Tenancy
  autoload :Resource,      'tenancy/resource'
  autoload :ResourceScope, 'tenancy/resource_scope'
end