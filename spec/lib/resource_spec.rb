require "spec_helper"

if defined?(ActiveRecord)
  describe "Tenancy::Resource" do
    let(:camyp)   { Portal.create(id: 1, domain_name: "yp.com.kh") }
    let(:panpage) { Portal.create(id: 2, domain_name: "panpages.my") }
    let(:yoolk)   { Portal.create(id: 3, domain_name: "yoolk.com") }

    it "set current with instance" do
      Portal.current = camyp

      expect(Portal.current).to eq(camyp)
      expect(RequestStore.store[:"Portal.current"]).to eq(camyp)
    end

    it "set current with id" do
      Portal.current = panpage.id

      expect(Portal.current).to eq(panpage)
      expect(RequestStore.store[:"Portal.current"]).to eq(panpage)
    end

    it "set current with nil" do
      Portal.current = panpage
      Portal.current = nil

      expect(Portal.current).to eq(nil)
      expect(RequestStore.store[:"Portal.current"]).to eq(nil)
    end

    it "#current_id" do
      Portal.current = yoolk

      expect(Portal.current_id).to eq(yoolk.id)
    end

    it "#with_scope with block" do
      expect(Portal.current).to eq(nil)

      Portal.with_tenant(yoolk) do
        expect(Portal.current).to eq(yoolk)
      end

      expect(Portal.current).to eq(nil)
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

      expect(Mongo::Portal.current).to eq(camyp)
      expect(RequestStore.store[:"Mongo::Portal.current"]).to eq(camyp)
    end

    it "set current with id" do
      Mongo::Portal.current = panpage.id

      expect(Mongo::Portal.current).to eq(panpage)
      expect(RequestStore.store[:"Mongo::Portal.current"]).to eq(panpage)
    end

    it "set current with nil" do
      Mongo::Portal.current = panpage
      Mongo::Portal.current = nil

      expect(Mongo::Portal.current).to eq(nil)
      expect(RequestStore.store[:"Mongo::Portal.current"]).to eq(nil)
    end

    it "#current_id" do
      Mongo::Portal.current = yoolk

      expect(Mongo::Portal.current_id).to eq(yoolk.id)
    end

    it "#with_scope with block" do
      expect(Mongo::Portal.current).to eq(nil)

      Mongo::Portal.with_tenant(yoolk) do
        expect(Mongo::Portal.current).to eq(yoolk)
      end

      expect(Mongo::Portal.current).to eq(nil)
    end

    it "#with_scope without block" do
      expect { Mongo::Portal.with_tenant(yoolk) }.to raise_error(ArgumentError)
    end
  end
end