# == Schema Information
#
# Table name: account_contacts
#
#  id         :integer         not null, primary key
#  account_id :integer
#  contact_id :integer
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe FatFreeCrm::AccountContact do
  before(:each) do
    @valid_attributes = {
      :account => mock_model(FatFreeCrm::Account),
      :contact => mock_model(FatFreeCrm::Contact)
    }
  end

  it "should create a new instance given valid attributes" do
    FatFreeCrm::AccountContact.create!(@valid_attributes)
  end
end

