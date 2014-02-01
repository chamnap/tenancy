module Tenancy
  module Resource
    extend ActiveSupport::Concern

    module ClassMethods

      def current=(value)
        tenant = case value
        when self
          value
        when nil
          nil
        else
          find(value)
        end

        RequestStore.store[:"#{name}.current"] = tenant
      end

      def current
        RequestStore.store[:"#{name}.current"]
      end

      def current_id
        current.try(:id)
      end

      def with_tenant(tenant, &block)
        raise ArgumentError, "block required" if block.nil?

        begin
          old          = self.current
          self.current = tenant

          block.call
        ensure
          self.current = old
        end
      end
      alias_method :use_tenant, :with_tenant
    end
  end
end
