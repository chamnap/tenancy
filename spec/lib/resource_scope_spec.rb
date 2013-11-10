require 'spec_helper'

describe "Tenancy::ResourceScope" do
  let(:camyp)     { Portal.create(domain_name: 'yp.com.kh') }
  let(:panpages)  { Portal.create(domain_name: 'panpages.com') }
  let(:listing)   { Listing.create(name: 'Listing 1', portal_id: camyp.id) }

  after(:all) do
    Portal.delete_all
  end

  describe Listing do
    it { should belong_to(:portal) }

    it { should validate_presence_of(:portal) }

    it { should validate_uniqueness_of(:name).scoped_to(:portal_id).case_insensitive }

    it "have default_scope with :portal_id field" do
      Portal.current = camyp

      expect(Listing.where(nil).to_sql).to eq(Listing.where(portal_id: Portal.current_id).to_sql)
    end

    it "doesn't have default_scope when it doesn't have current portal" do
      Portal.current = nil

      expect(Listing.where(nil).to_sql).not_to include(%{"listings"."portal_id" = #{Portal.current_id}})
    end
  end

  describe Communication do
    it { should belong_to(:portal) }

    it { should validate_presence_of(:portal) }

    it { should belong_to(:listing) }

    it { should validate_presence_of(:listing) }

    it { should validate_uniqueness_of(:value).scoped_to(:portal_id, :listing_id) }

    it "have default_scope with :portal_id field" do
      Portal.current  = camyp
      Listing.current = listing

      Communication.where(nil).to_sql.should == Communication.where(portal_id: Portal.current_id, listing_id: Listing.current_id).to_sql
    end

    it "doesn't have default_scope when it doesn't have current portal and listing" do
      Portal.current  = nil
      Listing.current = nil

      expect(Communication.where(nil).to_sql).not_to include(%{"communications"."portal_id" = #{Portal.current_id}})
      expect(Communication.where(nil).to_sql).not_to include(%{"communications"."listing_id" = #{Listing.current_id}})
    end
  end

  describe ExtraCommunication do
    it { should belong_to(:portal) }

    it { should belong_to(:listing) }

    it "raise exception when passing two resources and options" do
      expect { ExtraCommunication.scope_to(:portal, :listing, class_name: 'Listing') }.to raise_error(ArgumentError)
    end

    it "uses the correct scope" do
      listing2 = Listing.create(name: 'Name 2', portal: camyp)

      Portal.current = camyp
      Listing.current = listing2

      extra_communication = ExtraCommunication.new
      expect(extra_communication.listing_id).to eq(listing2.id)
      expect(extra_communication.portal_id).to eq(camyp.id)
    end
  end

  describe "belongs_to method override" do
    before(:each) { Portal.current = camyp }
    after(:each)  { Portal.current = nil }

    it "reload belongs_to when passes true" do
      listing.portal.domain_name = 'abc.com'
      expect(listing.portal(true).object_id).not_to eq(Portal.current.object_id)
    end

    it "doesn't reload belongs_to" do
      listing.portal.domain_name = 'abc.com'
      expect(listing.portal.object_id).to eq(Portal.current.object_id)
    end

    it "returns different object" do
      listing.portal_id = panpages.id
      expect(listing.portal.object_id).not_to eq(Portal.current.object_id)
    end

    it "doesn't touch db" do
      current_listing = listing

      Portal.establish_connection(adapter: "sqlite3", database: "spec/invalid.sqlite3")
      expect(current_listing.portal.object_id).to eq(Portal.current.object_id)

      Portal.establish_connection(ActiveRecord::Base.connection_config)
    end
  end

  describe "#without_scope" do
    before(:each) { Portal.current = camyp }
    after(:each)  { Portal.current = nil and Listing.current = nil }

    it "unscopes :current_portal" do
      expect(Listing.without_scope(:portal).to_sql).not_to include(%{"listings"."portal_id" = #{Portal.current_id}})
    end

    it "unscopes :current_portal and :current_listing" do
      Listing.current = listing

      expect(Communication.without_scope(:portal).to_sql).not_to include(%{"communications"."portal_id" = #{Portal.current_id}})
      expect(Communication.without_scope(:listing).to_sql).not_to include(%{"communications"."listing_id" = #{Listing.current_id}})
      expect(Communication.without_scope(:portal, :listing).to_sql).to eq(%{SELECT "communications".* FROM "communications"  WHERE "communications"."is_active" = 't'})
    end
  end
end