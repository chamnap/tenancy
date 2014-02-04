# Tenancy [![Gem Version](https://badge.fury.io/rb/tenancy.png)](http://badge.fury.io/rb/tenancy) [![Build Status](https://travis-ci.org/yoolk/tenancy.png?branch=master)](https://travis-ci.org/yoolk/tenancy) [![Dependency Status](https://gemnasium.com/yoolk/tenancy.png)](https://gemnasium.com/yoolk/tenancy) [![Coverage Status](https://coveralls.io/repos/yoolk/tenancy/badge.png?branch=master)](https://coveralls.io/r/yoolk/tenancy?branch=master)

**Tenancy** is a simple gem that provides multi-tenancy support on activerecord/mongoid (3/4) through scoping. I suggest you to watch an excellent [RailsCast on Multitenancy with Scopes](http://railscasts.com/episodes/388-multitenancy-with-scopes) and read this book [Multitenancy with Rails](https://leanpub.com/multi-tenancy-rails).

This `README.md` file is for the latest version, v1.0.0. For the previous version, check out this [README.md](https://github.com/yoolk/tenancy/blob/v0.2.0/README.md). Please, see the [CHANGELOG.md](https://github.com/yoolk/tenancy/blob/master/CHANGELOG.md#100) to do an upgrade.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "tenancy"
```

And then execute:

```
$ bundle
```

## Usage

This gem provides two modules: `Tenancy::Resource` and `Tenancy::ResourceScope`. Include them into your activerecord/mongoid models.

### Tenancy::Resource

`Tenancy::Resource` is a module which you want others to be scoped by.

```ruby
class Portal < ActiveRecord::Base
  include Tenancy::Resource
end

camyp = Portal.where(domain_name: 'yp.com.kh').first
# => <Portal id: 1, domain_name: 'yp.com.kh'>

# set current portal by id
Portal.current = camyp

# or portal object
Portal.current = 1

# get current portal
Portal.current
# => <Portal id: 1, domain_name: 'yp.com.kh'>

# scope with this portal
Portal.with_tenant(camyp) do
  # Do something here with this portal
end
```

### Tenancy::ResourceScope

`Tenancy::ResourceScope` is a module which you want to scope itself to `Tenancy::Resource`.

```ruby
class Listing < ActiveRecord::Base
  include Tenancy::Resource
  include Tenancy::ResourceScope

  scope_to :portal
  validates_uniqueness_in_scope :name, case_sensitive: false
end

class Communication < ActiveRecord::Base
  include Tenancy::ResourceScope

  scope_to :portal, :listing
  default_scope -> { where(is_active: true) }
  validates_uniqueness_in_scope :value
end

class ExtraCommunication < ActiveRecord::Base
  include Tenancy::ResourceScope

  # options here will send to #belongs_to
  scope_to :portal, class_name: 'Portal'
  scope_to :listing, class_name: 'Listing'
  validates_uniqueness_in_scope :value
end

> Portal.current = 1
> Listing.find(1)
# => SELECT "listings".* FROM "listings" WHERE "portal_id" = 1 AND "id" = 1

> Listing.current = 1
> Communication.find(1)
# => SELECT "communications".* FROM "communications" WHERE "portal_id" = 1 AND "listing_id" = 1 AND "is_active" = true AND "id" = 1

# include/exclude tenant_scope :current_portal, :current_listing
> Communication.tenant_scope(:portal).find(1)
# => SELECT "communications".* FROM "communications" WHERE "portal_id" = 1 AND "is_active" = true AND "id" = 1
> Communication.tenant_scope(:listing).find(1)
# => SELECT "communications".* FROM "communications" WHERE "listing_id" = 1 AND "is_active" = true AND "id" = 1
> Communication.tenant_scope(nil).find(1)
# => SELECT "communications".* FROM "communications" WHERE "is_active" = true AND "id" = 1
```

`scope_to :portal` does 4 things:

1. it adds `belongs_to :portal`.

2. it adds `validates :portal, presence: true`.

3. it adds `default_scope { where(portal_id: Portal.current) if Portal.current }`.

4. it overrides `#portal` so that it doesn't touch the database if `portal_id` in that record is the same as `Portal.current_id`.

5. it overrides `#portal_id` so that it returns `Portal.current_id`. (mongoid 3 only)

6. it overrides `#shard_key_selector` so that every update/delete query includes current tenant_id. (mongoid 3/4)

`validates :value, uniqueness: true` will validates uniqueness against the whole table. `validates_uniqueness_in_scope` validates uniqueness with the scopes you passed in `scope_to`.

## Rails

```ruby
class ApplicationController < ActionController::Base
  before_action :set_current_portal

  protected

    def current_portal
      Portal.current
    end

    def set_current_portal
      Portal.current = Portal.find_by_domain_name(request.host)
    end
end
```

## Indexes

```ruby
add_index :listings, :portal_id
add_index :communications, [:portal_id, :listing_id]
```

## RSpec

In spec_helper.rb, you'll need to require the matchers:

```ruby
require "tenancy/matchers"
```

Example:

```ruby
describe Portal do
  it { should be_a_tenant }
end
```

```ruby
describe Listing do
  it { should have_scope_to(:portal) }
  it { should have_scope_to(:portal).class_name('Portal') }
end
```

```ruby
describe Mongo::Listing do
  it { should have_scope_to(:portal) }
  it { should have_scope_to(:portal).of_type(Mongo::Portal) }
end
```

I have this rspec configuration in my rails 4 apps:

```ruby
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:mongoid].strategy       = :truncation

    DatabaseCleaner[:active_record].clean_with(:truncation)
    DatabaseCleaner[:mongoid].clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner[:active_record].start
    DatabaseCleaner[:mongoid].start

    current_portal = FactoryGirl.create(:portal, domain_name: "yellowpages-cambodia.dev")
    Yoolk::Portal.use(current_portal) do
      example.run
    end

    DatabaseCleaner[:active_record].clean
    DatabaseCleaner[:mongoid].clean if example.metadata[:mongodb]
  end
end
```

## Authors

* [Chamnap Chhorn](https://github.com/chamnap)