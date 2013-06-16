class Portal < ActiveRecord::Base
  include Tenancy::Resource
end

class Listing < ActiveRecord::Base
  include Tenancy::Resource
  include Tenancy::ResourceScope

  scope_to :portal
  validates_uniqueness_in_scope :name, case_sensitive: false
end

class Communication < ActiveRecord::Base
  include Tenancy::ResourceScope

  scope_to :portal, :listing
  validates_uniqueness_in_scope :value
end