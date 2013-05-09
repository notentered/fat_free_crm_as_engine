# == Schema Information
#
# Table name: account_opportunities
#
#  id             :integer         not null, primary key
#  account_id     :integer
#  opportunity_id :integer
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe FatFreeCrm::AccountOpportunity do
  before(:each) do
    @valid_attributes = {
      :account => mock_model(FatFreeCrm::Account),
      :opportunity => mock_model(FatFreeCrm::Opportunity)
    }
  end

  it "should create a new instance given valid attributes" do
    FatFreeCrm::AccountOpportunity.create!(@valid_attributes)
  end
end

