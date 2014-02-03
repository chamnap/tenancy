module Tenancy
  class Scoping
    autoload :ActiveRecord, "tenancy/scoping/active_record"
    autoload :Mongoid,      "tenancy/scoping/mongoid"

    attr_reader :klass, :tenants

    def initialize(klass)
      @klass   = klass
      @tenants = []
    end
  end
end