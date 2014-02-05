require "spec_helper"

if defined?(ActiveRecord)
  describe "Tenancy::Resource" do
    let(:camyp)   { Portal.create(id: 1, domain_name: "yp.com.kh") }
    let(:panpage) { Portal.create(id: 2, domain_name: "panpages.my") }
    let(:yoolk)   { Portal.create(id: 3, domain_name: "yoolk.com") }

    it "set current with instance" do
      Portal.current = camyp

      Portal.current.should == camyp
      RequestStore.store[:"Portal.current"].should == camyp
    end

    it "set current with id" do
      Portal.current = panpage.id

      Portal.current.should == panpage
      RequestStore.store[:"Portal.current"].should == panpage
    end

    it "set current with nil" do
      Portal.current = panpage
      Portal.current = nil

      Portal.current.should == nil
      RequestStore.store[:"Portal.current"].should == nil
    end

    it "#current_id" do
      Portal.current = yoolk

      Portal.current_id.should == yoolk.id
    end

    it "#with_scope with block" do
      Portal.current.should == nil

      Portal.with_tenant(yoolk) do
        Portal.current.should == yoolk
      end

      Portal.current.should == nil
    end

    it "#with_scope without block" do
      expect { Portal.with_tenant(yoolk) }.to raise_error(ArgumentError)
    end
  end
end

if defined?(Mongoid)
  describe "Tenancy::Resource" do
    let(:camyp)   { Mongo::Portal.create(domain_name: "yp.com.kh") }
    let(:panpage) { Mongo::Portal.create(domain_name: "panpages.my") }
    let(:yoolk)   { Mongo::Portal.create(domain_name: "yoolk.com") }

    it "set current with instance" do
      Mongo::Portal.current = camyp

      Mongo::Portal.current.should == camyp
      RequestStore.store[:"Mongo::Portal.current"].should == camyp
    end

    it "set current with id" do
      Mongo::Portal.current = panpage.id

      Mongo::Portal.current.should == panpage
      RequestStore.store[:"Mongo::Portal.current"].should == panpage
    end

    it "set current with nil" do
      Mongo::Portal.current = panpage
      Mongo::Portal.current = nil

      Mongo::Portal.current.should == nil
      RequestStore.store[:"Mongo::Portal.current"].should == nil
    end

    it "#current_id" do
      Mongo::Portal.current = yoolk

      Mongo::Portal.current_id.should == yoolk.id
    end

    it "#with_scope with block" do
      Mongo::Portal.current.should == nil

      Mongo::Portal.with_tenant(yoolk) do
        Mongo::Portal.current.should == yoolk
      end

      Mongo::Portal.current.should == nil
    end

    it "#with_scope without block" do
      expect { Mongo::Portal.with_tenant(yoolk) }.to raise_error(ArgumentError)
    end
  end
end