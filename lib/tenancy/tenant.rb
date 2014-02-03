module Tenancy
  class Tenant
    attr_accessor :name, :klass, :klass_name, :foreign_key

    def initialize(name, klass_name, host_klass)
      @name        = name.to_sym
      @klass_name  = (klass_name.to_s.presence || name.to_s).classify
      @klass       = @klass_name.constantize
      @foreign_key = host_klass.reflect_on_association(@name).foreign_key.to_sym
    end

  end
end