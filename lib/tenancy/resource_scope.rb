module Tenancy
  module ResourceScope
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :scope_fields

      def scope_to(*resources)
        @scope_fields    = []
        resources.each do |resource|
          resource          = resource.to_sym
          resource_class    = resource.to_s.classify.constantize
          association_name  = self.to_s.downcase.pluralize.to_sym
          
          # validates and belongs_to
          validates         resource, presence:   true
          belongs_to        resource, class_name: resource_class

          # default_scope
          foreign_key       = reflect_on_association(resource).foreign_key
          @scope_fields     << foreign_key
          default_scope     { where(:"#{foreign_key}" => resource_class.current_id) if resource_class.current_id }

          # has_many
          resource_class.has_many association_name, class_name: self.to_s
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