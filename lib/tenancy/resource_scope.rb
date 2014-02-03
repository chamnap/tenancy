module Tenancy
  module ResourceScope
    extend ActiveSupport::Concern

    module ClassMethods

      def scope_to(*resources)
        tenancy_scoping.scope_to(resources)
      end

      def tenant_scope(*resources)
        tenancy_scoping.tenant_scope(resources)
      end

      def validates_uniqueness_in_scope(fields, args={})
        tenancy_scoping.validates_uniqueness_in_scope(fields, args)
      end

      private

        def tenancy_scoping
          @tenancy_scoping ||= if defined?(::ActiveRecord) && ancestors.include?(::ActiveRecord::Base)
            Scoping::ActiveRecord.new(self)
          elsif defined?(Mongoid) && ancestors.include?(Mongoid::Document)
            Scoping::Mongoid.new(self)
          end
        end
    end
  end
end
