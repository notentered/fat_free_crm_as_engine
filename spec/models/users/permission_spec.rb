# == Schema Information
#
# Table name: permissions
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  asset_id   :integer
#  asset_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe FatFreeCrm::Permission do
  before(:each) do
    @valid_attributes = {
      :user => mock_model(FatFreeCrm::User),
      :asset => mock_model(FatFreeCrm::Account)
    }
  end

  it "should create a new instance given valid attributes" do
    FatFreeCrm::Permission.create!(@valid_attributes)
  end
  
  it "should validate with group_ids" do
    p = FatFreeCrm::Permission.new :group_id => 1
    p.should be_valid
  end
  
  it "should validate with user_ids" do
    p = FatFreeCrm::Permission.new :user_id => 2
    p.should be_valid
  end
  
  it "should validate not allow group_ids or user_ids to be blank" do
    p = FatFreeCrm::Permission.new
    p.should_not be_valid
    p.errors['user_id'].should  == ["can't be blank"]
    p.errors['group_id'].should == ["can't be blank"]
  end
  
end
