module Tenancy
  module ResourceScope
    extend ActiveSupport::Concern

    module ClassMethods
      def tenancy_scope
        @tenancy_scope ||= if superclass == ::ActiveRecord::Base
          Scoping::ActiveRecord.new(self)
        elsif Mongoid::Document.in? self.included_modules
          Scoping::Mongoid.new(self)
        end
      end

      def scope_to(*resources)
        tenancy_scope.scope_to(resources)
      end

      def without_scope(*resources)
        tenancy_scope.without_scope(resources)
      end

      def only_scope(*resources)
        tenancy_scope.only_scope(resources)
      end

      def validates_uniqueness_in_scope(fields, args={})
        tenancy_scope.validates_uniqueness_in_scope(fields, args)
      end
    end
  end
end
