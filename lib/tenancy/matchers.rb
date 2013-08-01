require 'shoulda-matchers'

module Tenancy
  module Shoulda
    module Matchers
      def have_scope_to(name)
        HaveScopeToMatcher.new(name)
      end

      class HaveScopeToMatcher
        def initialize(scope_name)
          @scope_name        = scope_name
          @presence_matcher  = ::Shoulda::Matchers::ActiveModel::ValidatePresenceOfMatcher.new(@scope_name)
          @belong_to_matcher = ::Shoulda::Matchers::ActiveRecord::AssociationMatcher.new(:belongs_to, @scope_name)
        end

        def matches?(subject)
          @presence_matches      = @presence_matcher.matches?(subject)
          @belong_to_matches     = @belong_to_matcher.matches?(subject)
          @default_scope_matches = default_scope_matches?(subject)
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
          def default_scope_matches?(subject)
            actual_class = subject.class
            reflection   = actual_class.reflect_on_association(@scope_name.to_sym)
            scoped_class = reflection.class_name.constantize

            if scoped_class.current_id
              actual_class.scoped.to_sql.include? %Q{#{actual_class.quoted_table_name}.#{scoped_class.connection.quote_column_name(reflection.foreign_key)} = #{scoped_class.connection.quote(scoped_class.current_id)}}
            else
              true
            end
          end

          def method_missing(method, *args, &block)
            if @belong_to_matcher.respond_to?(method)
              @belong_to_matcher.send(method, *args, &block)
            else
              super
            end
          end
      end
    end
  end
end


require 'rspec/core'
RSpec.configure do |config|
  config.include Tenancy::Shoulda::Matchers
end