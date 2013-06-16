require 'spec_helper'

describe "Tenancy::Resource" do
  before(:all) do
    @camyp   = Portal.create(id: 1, domain_name: 'yp.com.kh')
    @panpage = Portal.create(id: 2, domain_name: 'panpages.my')
    @yoolk   = Portal.create(id: 3, domain_name: 'yoolk.com')
  end

  after(:all) do
    Portal.delete_all
  end

  before(:each) { Thread.current[:current_portal] = nil }

  it "set current with instance" do
    Portal.current = @camyp

    Portal.current.should == @camyp
    Thread.current[:current_portal].should == @camyp
  end

  it "set current with id" do
    Portal.current = @panpage.id

    Portal.current.should == @panpage
    Thread.current[:current_portal].should == @panpage
  end

  it "set current with nil" do
    Portal.current = @panpage
    Portal.current = nil

    Portal.current.should == nil
    Thread.current[:current_portal].should == nil
  end

  it "#current_id" do
    Portal.current = @yoolk

    Portal.current_id.should == @yoolk.id
  end

  it "#with with block" do
    Portal.current.should == nil

    Portal.with(@yoolk) do
      Portal.current.should == @yoolk
    end

    Portal.current.should == nil
  end

  it "#with without block" do
    expect { Portal.with(@yoolk) }.to raise_error(ArgumentError)
  end
end