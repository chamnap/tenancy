require 'spec_helper'
require 'tenancy/matchers'

describe ExtraCommunication do
  let(:camyp) { Portal.create(domain_name: 'yp.com.kh') }
  before      { Portal.current = camyp }

  it { should have_scope_to(:portal) }
  it { should have_scope_to(:portal).class_name('Portal') }
  it { should have_scope_to(:listing) }
  it { should have_scope_to(:listing).class_name('Listing') }
end