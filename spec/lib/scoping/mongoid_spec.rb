require "spec_helper"

if defined?(Mongoid)
  describe "Tenancy::Scoping::Mongoid", mongoid: true do
    let(:camyp)     { Mongo::Portal.create(domain_name: "yp.com.kh") }
    let(:panpages)  { Mongo::Portal.create(domain_name: "panpages.com") }
    let(:listing)   { Mongo::Listing.create(name: "Listing 1", portal_id: camyp.id) }

    describe Mongo::Listing do
      it { should belong_to(:portal).of_type(Mongo::Portal) }

      it { should validate_presence_of(:portal) }

      it { should validate_uniqueness_of(:name).scoped_to(:portal_id).case_insensitive }

      it "have default_scope with :portal_id field" do
        Mongo::Portal.current = camyp

        expect(Mongo::Listing.where(nil).selector).to eq({"is_active"=>true, "portal_id"=>Mongo::Portal.current_id})
      end

      it "doesn't have default_scope when it doesn't have current portal" do
        Mongo::Portal.current = nil

        expect(Mongo::Listing.where(nil).selector).to eq({"is_active"=>true})
      end
    end

    describe Mongo::Communication do
      it { should belong_to(:portal) }

      it { should validate_presence_of(:portal) }

      it { should belong_to(:listing) }

      it { should validate_presence_of(:listing) }

      it { should validate_uniqueness_of(:value).scoped_to(:portal_id, :listing_id) }

      it "have default_scope with :portal_id field" do
        Mongo::Portal.current  = camyp
        Mongo::Listing.current = listing

        expect(Mongo::Communication.where(nil).selector).to eq({"is_active"=>true, "portal_id"=>Mongo::Portal.current_id, "listing_id"=>Mongo::Listing.current_id})
      end

      it "doesn't have default_scope when it doesn't have current portal and listing" do
        Mongo::Portal.current  = nil
        Mongo::Listing.current = nil

        expect(Mongo::Communication.where(nil).selector).to eq({"is_active"=>true})
      end
    end

    describe Mongo::ExtraCommunication do
      it { should belong_to(:portal).of_type(Mongo::Portal) }

      it { should belong_to(:listing).of_type(Mongo::Listing) }

      it "raise exception when passing two resources and options" do
        expect { Mongo::ExtraCommunication.scope_to(:portal, :listing, class_name: "Mongo::Listing") }.to raise_error(ArgumentError)
      end

      it "uses the correct scope", :pending do
        listing2 = Mongo::Listing.create(name: "Name 2", portal: camyp)

        Mongo::Portal.current = camyp
        Mongo::Listing.current = listing2

        extra_communication = Mongo::ExtraCommunication.new
        expect(extra_communication.listing_id).to eq(listing2.id)
        expect(extra_communication.portal_id).to eq(camyp.id)
      end
    end

    describe "belongs_to method override" do
      before(:each) { Mongo::Portal.current = camyp }
      after(:each)  { Mongo::Portal.current = nil }

      it "reload belongs_to when passes true" do
        listing.portal.domain_name = "abc.com"

        expect(listing.portal(true).object_id).not_to eq(Mongo::Portal.current.object_id)
      end

      it "doesn't reload belongs_to" do
        listing.portal.domain_name = "abc.com"

        expect(listing.portal.object_id).to eq(Mongo::Portal.current.object_id)
      end

      it "returns different object" do
        listing.portal_id = panpages.id

        expect(listing.portal.object_id).not_to eq(Mongo::Portal.current.object_id)
      end

      it "doesn't touch db" do
        current_listing = listing

        Mongo::Portal.store_in session: ""
        expect(current_listing.portal.object_id).to eq(Mongo::Portal.current.object_id)
        Mongo::Portal.store_in session: "default"
      end
    end

    describe "#without_scope" do
      before(:each) { Mongo::Portal.current = camyp }
      after(:each)  { Mongo::Portal.current = nil and Mongo::Listing.current = nil }

      it "unscopes :current_portal" do
        expect(Mongo::Listing.without_scope(:portal).selector).to eq({"is_active"=>true})
      end

      it "unscopes :current_portal and :current_listing" do
        Mongo::Listing.current = listing

        expect(Mongo::Communication.without_scope(:portal).selector).to eq({"is_active"=>true, "listing_id"=>Mongo::Listing.current_id})
        expect(Mongo::Communication.without_scope(:listing).selector).to eq({"is_active"=>true, "portal_id"=>Mongo::Portal.current_id})
        expect(Mongo::Communication.without_scope(:portal, :listing).selector).to eq({"is_active"=>true})
      end
    end

    describe "#only_scope" do
      before(:each) { Mongo::Portal.current = camyp }
      after(:each)  { Mongo::Portal.current = nil and Mongo::Listing.current = nil }

      it "scopes only :current_portal" do
        Mongo::Listing.current = listing

        expect(Mongo::Communication.only_scope(:portal).selector).to eq({"is_active"=>true, "portal_id"=>Mongo::Portal.current_id})
      end

      it "scopes only :current_listing" do
        Mongo::Listing.current = listing

        expect(Mongo::Communication.only_scope(:listing).selector).to eq({"is_active"=>true, "listing_id"=>Mongo::Listing.current_id})
      end

      it "scopes only :current_listing and :current_portal" do
        Mongo::Listing.current = listing

        expect(Mongo::Communication.only_scope(:listing, :portal).selector).to eq(Mongo::Communication.where(nil).selector)
      end
    end
  end
end