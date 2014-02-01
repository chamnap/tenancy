module Tenancy
  class Scoping::Mongoid < Scoping

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
        klass.default_scope  lambda {
          if resource_class.current_id
            klass.where(:"#{resource_foreign_key}" => resource_class.current_id)
          else
            klass.where(nil)
          end
        }

        # override to return current resource instance
        # so that it doesn't touch db
        klass.send(:define_method, "#{resource}_with_current", lambda { |reload=false|
          return send(:"#{resource}_without_current", reload) if reload
          return resource_class.current if send(resource_foreign_key) == resource_class.current_id
          send(:"#{resource}_without_current", reload)
        })
        klass.alias_method_chain :"#{resource}", :current
      end

      def without_scope(resources)
        scope = klass.where(nil)

        resources.each do |resource|
          reflection = resource_reflection(resource)
          next       if reflection.nil?

          scope.selector.delete(reflection.foreign_key)
        end

        scope
      end

      def only_scope(resources)
        scope = klass.where(nil)
        delete_resources = scoped_resources - resources
        delete_resources.each do |resource|
          reflection = resource_reflection(resource)
          next       if reflection.nil?

          scope.selector.delete(reflection.foreign_key)
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
    end

    private

      def resource_reflection(resource)
        klass.reflect_on_association(resource.to_sym)
      end
  end
end