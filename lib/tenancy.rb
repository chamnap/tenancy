require "tenancy/version"
require "active_support/concern"
require "request_store"

module Tenancy
  autoload :Resource,      "tenancy/resource"
  autoload :ResourceScope, "tenancy/resource_scope"
  autoload :Scoping,       "tenancy/scoping"
  autoload :Tenant,        "tenancy/tenant"
end