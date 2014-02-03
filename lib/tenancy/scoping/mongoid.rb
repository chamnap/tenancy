module Tenancy
  class Scoping::Mongoid < Scoping

    def scope_to(tenant_names)
      options = tenant_names.extract_options!.dup
      raise ArgumentError, "options should be blank if there are multiple tenants" if tenant_names.count > 1 and options.present?

      tenant_names.each do |tenant_name|
        # validates and belongs_to
        klass.validates         tenant_name, presence: true
        klass.belongs_to        tenant_name, options

        tenant                  = Tenant.new(tenant_name, options[:class_name], klass)
        self.tenants            << tenant

        # default_scope
        klass.default_scope  lambda {
          if tenant.klass.current_id
            klass.where(:"#{tenant.foreign_key}" => tenant.klass.current_id)
          else
            klass.where(nil)
          end
        }

        # override to return current tenant_name instance
        # so that it doesn't touch db
        klass.send(:define_method, :"#{tenant_name}_with_tenant", lambda { |reload=false|
          return send(:"#{tenant_name}_without_tenant", reload) if reload
          return tenant.klass.current if send(tenant.foreign_key) == tenant.klass.current_id
          send(:"#{tenant_name}_without_tenant", reload)
        })
        klass.alias_method_chain :"#{tenant_name}", :tenant
      end

      # tenants variable is for lambda
      tenants = self.tenants
      klass.send(:define_method, :shard_key_selector, lambda {
        selector = super()
        tenants.each do |tenant|
          selector[tenant.foreign_key.to_s] = send(tenant.foreign_key) if tenant.klass.current_id
        end
        selector
      })
    end

    def tenant_scope(tenant_names)
      scope = klass.where(nil)
      tenants.each do |tenant|
        next if tenant_names.include?(tenant.name.to_sym)

        scope.selector.delete(tenant.foreign_key)
      end

      scope
    end

    def validates_uniqueness_in_scope(fields, args={})
      foreign_keys = tenants.map(&:foreign_key)
      if args[:scope]
        args[:scope] = Array.wrap(args[:scope]) << foreign_keys
      else
        args[:scope] = foreign_keys
      end

      klass.validates_uniqueness_of(fields, args)
    end
  end
end