module Tenancy
  class Scoping::ActiveRecord < Scoping

    def scope_to(tenant_names)
      options = tenant_names.extract_options!.dup
      raise ArgumentError, "options should be blank if there are multiple tenants" if tenant_names.count > 1 and options.present?

      tenant_names.each do |tenant_name|
        # validates and belongs_to
        klass.validates   tenant_name, presence: true
        klass.belongs_to  tenant_name, options

        tenant            = Tenant.new(tenant_name, options[:class_name], klass)
        self.tenants      << tenant

        # default_scope
        klass.send(:default_scope, lambda { klass.where(:"#{tenant.foreign_key}" => tenant.klass.current_id) if tenant.klass.current_id })

        # override to return current tenant instance
        # so that it doesn"t touch db
        klass.send(:define_method, tenant_name, lambda { |reload=false|
          return super(reload) if reload
          return tenant.klass.current if send(tenant.foreign_key) == tenant.klass.current_id
          super(reload)
        })
      end
    end

    def tenant_scope(tenant_names)
      if ::ActiveRecord::VERSION::MAJOR == 4 &&  ::ActiveRecord::VERSION::MINOR >= 1
        foreign_keys = if tenant_names.blank?
          tenants.map(&:foreign_key)
        else
          tenants.reject { |tenant| tenant_names.include?(tenant.name) }.map(&:foreign_key)
        end
        klass.unscope(where: foreign_keys)
      else
        scope = default_scoped
        tenants.each do |tenant|
          next if tenant_names.include?(tenant.name.to_sym)

          tenant_scope_sql = klass.where(nil).table[tenant.foreign_key].eq(tenant.klass.current_id).to_sql
          scope.where_values.delete_if { |query| query.to_sql == tenant_scope_sql }
        end

        scope
      end
    end

    def default_scoped
      if ::ActiveRecord::VERSION::MAJOR == 4 && ::ActiveRecord::VERSION::MINOR >= 1
        klass.where(nil).default_scoped
      else
        klass.where(nil).with_default_scope
      end
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