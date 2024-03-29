# == Schema Information
#
# Table name: addresses
#
#  id               :integer         not null, primary key
#  street1          :string(255)
#  street2          :string(255)
#  city             :string(64)
#  state            :string(64)
#  zipcode          :string(16)
#  country          :string(64)
#  full_address     :string(255)
#  address_type     :string(16)
#  addressable_id   :integer
#  addressable_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe FatFreeCrm::Address do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    FatFreeCrm::Address.create!(:street1 => "street1", :street2 => "street2", :city => "city", :state => "state", :zipcode => "zipcode", :country => "country", :full_address => "fa", :address_type => "Lead", :addressable => FactoryGirl.create(:lead))
  end
end

