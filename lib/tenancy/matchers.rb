require "shoulda-matchers" if defined?(ActiveRecord)
require "mongoid-rspec"    if defined?(Mongoid)

module Tenancy
  module Shoulda
    module Matchers
      def have_scope_to(name)
        HaveScopeToMatcher.new(name)
      end

      def be_a_tenant
        BeATenant.new
      end

      class HaveScopeToMatcher
        attr_reader :scope_name

        def initialize(scope_name)
          @scope_name             = scope_name
          if defined?(ActiveRecord)
            @ar_presence_matcher    = ::Shoulda::Matchers::ActiveModel::ValidatePresenceOfMatcher.new(@scope_name)
            @ar_belong_to_matcher   = ::Shoulda::Matchers::ActiveRecord::AssociationMatcher.new(:belongs_to, @scope_name)
          end
          if defined?(Mongoid)
            @mid_presence_matcher   = ::Mongoid::Matchers::Validations::HaveValidationMatcher.new(@scope_name, :presence)
            @mid_belong_to_matcher  = ::Mongoid::Matchers::Associations::HaveAssociationMatcher.new(@scope_name, ::Mongoid::Matchers::Associations::BELONGS_TO)
          end
        end

        def matches?(subject)
          if defined?(ActiveRecord) && subject.class <= ::ActiveRecord::Base
            @ar_presence_matcher.matches?(subject) &&
            @ar_belong_to_matcher.matches?(subject) &&
            ar_default_scope_matches?(subject)
          elsif defined?(Mongoid) && subject.class <= ::Mongoid::Document
            @mid_presence_matcher.matches?(subject) &&
            @mid_belong_to_matcher.matches?(subject)
          end
        end

        def failure_message
          @presence_matcher.failure_message                   unless @presence_matches
          @belong_to_matcher.failure_message                  unless @belong_to_matches
          "Expected to have default_scope on :#{@scope_name}" unless @default_scope_matches
        end

        def description
          "require to have scope_to :#{@scope_name}"
        end

        private

          def ar_default_scope_matches?(subject)
            actual_class = subject.class
            reflection   = actual_class.reflect_on_association(@scope_name.to_sym)
            scoped_class = reflection.class_name.constantize

            if scoped_class.current_id
              actual_class.where(nil).to_sql.include? %Q{#{actual_class.quoted_table_name}.#{scoped_class.connection.quote_column_name(reflection.foreign_key)} = #{scoped_class.connection.quote(scoped_class.current_id)}}
            else
              true
            end
          end

          def method_missing(method, *args, &block)
            if @ar_belong_to_matcher && @ar_belong_to_matcher.respond_to?(method)
              @ar_belong_to_matcher.send(method, *args, &block)
            elsif @mid_belong_to_matcher && @mid_belong_to_matcher.respond_to?(method)
              @mid_belong_to_matcher.send(method, *args, &block)
            else
              super
            end
          end
      end

      class BeATenant
        attr_accessor :klass

        def matches?(instance)
          self.klass = instance.class
          klass.included_modules.include? Tenancy::Resource
        end

        def failure_message
          "Expected to call `include Tenancy::Resource` inside #{klass}"
        end

        def description
          "require to call `include Tenancy::Resource`"
        end
      end
    end
  end
end


require "rspec/core"
RSpec.configure do |config|
  config.include Tenancy::Shoulda::Matchers
end