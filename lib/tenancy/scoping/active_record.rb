module Tenancy
  class Scoping::ActiveRecord < Scoping

    def scope_to(resources)
      options = resources.extract_options!.dup
      raise ArgumentError, "options should be blank if there are multiple resources" if resources.count > 1 and options.present?

      resources.each do |resource|
        resource              = resource.to_sym
        resource_class_name ||= (options[:class_name].to_s.presence || resource.to_s).classify
        resource_class        = resource_class_name.constantize

        # validates and belongs_to
        klass.validates       resource, presence: true
        klass.belongs_to      resource, options

        # default_scope
        self.scoped_resources << resource
        resource_foreign_key  = resource_reflection(resource).foreign_key
        klass.send(:default_scope, lambda { klass.where(:"#{resource_foreign_key}" => resource_class.current_id) if resource_class.current_id })

        # override to return current resource instance
        # so that it doesn"t touch db
        klass.send(:define_method, resource, lambda { |reload=false|
          return super(reload) if reload
          return resource_class.current if send(resource_foreign_key) == resource_class.current_id
          super(reload)
        })
      end
    end

    # inspired by: https://github.com/goncalossilva/acts_as_paranoid/blob/rails3.2/lib/acts_as_paranoid/core.rb#L76
    def without_scope(resources)
      scope = klass.where(nil).with_default_scope
      resources.each do |resource|
        reflection = resource_reflection(resource)
        next       if reflection.nil?

        resource_scope_sql = klass.where(nil).table[reflection.foreign_key].eq(reflection.klass.current_id).to_sql
        scope.where_values.delete_if { |query| query.to_sql == resource_scope_sql }
      end

      scope
    end

    def only_scope(resources)
      scope = klass.where(nil).with_default_scope
      delete_resources = scoped_resources - resources
      delete_resources.each do |resource|
        reflection = resource_reflection(resource)
        next       if reflection.nil?

        resource_scope_sql = klass.where(nil).table[reflection.foreign_key].eq(reflection.klass.current_id).to_sql
        scope.where_values.delete_if { |query| query.to_sql == resource_scope_sql }
      end

      scope
    end

    def validates_uniqueness_in_scope(fields, args={})
      foreign_keys = scoped_resources.map { |resource| resource_reflection(resource).foreign_key }
      if args[:scope]
        args[:scope] = Array.wrap(args[:scope]) << foreign_keys
      else
        args[:scope] = foreign_keys
      end

      klass.validates_uniqueness_of(fields, args)
    end

    private
      def resource_reflection(resource)
        klass.reflect_on_association(resource.to_sym)
      end
  end
end