module Tenancy
  module ResourceScope
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :scope_fields

      def scope_fields
        @scope_fields ||= []
      end

      def scope_to(*resources)
        options = resources.extract_options!.dup
        raise ArgumentError, 'options should be blank if there are multiple resources' if resources.count > 1 and options.present?
        
        resources.each do |resource|
          resource          = resource.to_sym
          options[:class_name] ||= resource.to_s.classify
          resource_class    = options[:class_name].constantize
          association_name  = self.to_s.downcase.pluralize.to_sym
          
          # validates and belongs_to
          validates         resource, presence: true
          belongs_to        resource, options

          # default_scope
          foreign_key       = reflect_on_association(resource).foreign_key
          scope_fields     << foreign_key
          default_scope     { where(:"#{foreign_key}" => resource_class.current_id) if resource_class.current_id }
        end
      end

      def validates_uniqueness_in_scope(fields, args={})
        if args[:scope]
          args[:scope] = Array.wrap(args[:scope]) << scope_fields
        else
          args[:scope] = scope_fields
        end
        
        validates_uniqueness_of(fields, args)
      end
    end
  end
end