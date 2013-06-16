# Tenancy

`tenancy` is a simple gem that provides multi-tennacy support on activerecord through scoping. I suggest you to watch an excellent [RailsCast on Multitenancy with Scopes](http://railscasts.com/episodes/388-multitenancy-with-scopes) and read this book [Multitenancy with Rails](https://leanpub.com/multi-tenancy-rails).


## Installation

Add this line to your application's Gemfile:

    gem 'tenancy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tenancy

## Usage

This gem provides two modules: `Tenancy::Resource` and `Tenancy::ResourceScope`. 

### Tenancy::Resource

`Tenancy::Resource` is a module which you want others to be scoped by.

    class Portal < ActiveRecord::Base
      include Tenancy::Resource
    end

    >> camyp = Portal.where(domain_name: 'yp.com.kh').first
    => #<Portal id: 1, domain_name: 'yp.com.kh'>

    # set current portal by id
    >> Portal.current = camyp

    # or portal object
    >> Portal.current = 1

    # get current portal
    >> Portal.current
    => #<Portal id: 1, domain_name: 'yp.com.kh'>

    # scope with this portal
    Portal.with(camyp) do
      # Do something here with this portal
    end

### Tenancy::ResourceScope

`Tenancy::ResourceScope` is a module which you want to scope itself to `Tenancy::Resource`.

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

    >> Portal.current = 1
    >> Listing.find(1).to_sql
    => SELECT "listings".* FROM "listings" WHERE "portal_id" = 1

    >> Listing.current = 1
    >> Communication.find(1).to_sql
    => SELECT "communications".* FROM "communications" WHERE "portal_id" = 1 and "listing_id" = 1

`scope_to :portal` does four things:

1. it adds `belongs_to :portal`.

2. it adds `validates :portal, presence: true`.

3. it adds `default_scope { where(portal_id: Portal.current) if Portal.current }`.

4. it adds `has_many :listings` inside `Portal`.

`validates :value, uniqueness: true` will validates uniqueness against the whole table. `validates_uniqueness_in_scope` validates uniqueness with the scopes you passed in `scope_to`.