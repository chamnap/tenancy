require 'spec_helper'

describe "Tenancy::ResourceScope" do
  let(:camyp) { Portal.create(domain_name: 'yp.com.kh') }
  let(:listing1) { Listing.create(name: 'Listing 1', portal_id: camyp.id) }

  after(:all) do
    Portal.delete_all
  end

  describe Listing do
    it { should belong_to(:portal) }
    
    it { should validate_presence_of(:portal) }

    it { should validate_uniqueness_of(:name).scoped_to(:portal_id).case_insensitive }
    
    it "have default_scope with :portal_id field" do
      Portal.current = camyp

      Listing.scoped.to_sql.should == Listing.where(portal_id: Portal.current_id).to_sql
    end

    it "doesn't have default_scope when it doesn't have current portal" do
      Portal.current = nil

      Listing.scoped.to_sql.should == "SELECT \"listings\".* FROM \"listings\" "
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
      Listing.current = listing1

      Communication.scoped.to_sql.should == Communication.where(portal_id: Portal.current_id, listing_id: Listing.current_id).to_sql
    end

    it "doesn't have default_scope when it doesn't have current portal and listing" do
      Portal.current  = nil
      Listing.current = nil

      Communication.scoped.to_sql.should == "SELECT \"communications\".* FROM \"communications\" "
    end
  end

  describe ExtraCommunication do
    it { should belong_to(:portal) }

    it { should belong_to(:listing) }

    it "raise exception when passing two resources and options" do
      expect { ExtraCommunication.scope_to(:portal, :listing, class_name: 'Listing') }.to raise_error(ArgumentError)
    end
  end
end