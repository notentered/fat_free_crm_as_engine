# == Schema Information
#
# Table name: settings
#
#  id            :integer         not null, primary key
#  name          :string(32)      default(""), not null
#  value         :text
#  created_at    :datetime
#  updated_at    :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FatFreeCrm::Setting do

  it "should create a new instance given valid attributes" do
    FatFreeCrm::Setting.create!(:name => "name", :value => "value")
  end

  it "should find existing setting by its name using [] or method notations, and cache settings" do
    @setting = FactoryGirl.create(:setting, :name => "thingymabob", :value => "magoody")
    FatFreeCrm::Setting.cache.has_key?("thingymabob").should == false
    FatFreeCrm::Setting[:thingymabob].should == "magoody"
    FatFreeCrm::Setting.cache.has_key?("thingymabob").should == true
    FatFreeCrm::Setting.thingymabob.should == "magoody"
  end

  it "should use value from YAML if setting is missing from database" do
    @setting = FactoryGirl.create(:setting, :name => "magoody", :value => nil)
    FatFreeCrm::Setting.yaml_settings.merge!(:magoody => "thingymabob")
    FatFreeCrm::Setting[:magoody].should == "thingymabob"
    FatFreeCrm::Setting.magoody.should == "thingymabob"
  end

  it "should save a new value of a setting using []= or method notation" do
    FatFreeCrm::Setting[:hello] = "world"
    FatFreeCrm::Setting[:hello].should == "world"
    FatFreeCrm::Setting.hello.should == "world"

    FatFreeCrm::Setting.world = "hello"
    FatFreeCrm::Setting.world.should == "hello"
    FatFreeCrm::Setting[:world].should == "hello"
  end
  
  it "should handle false and nil values correctly" do
    FatFreeCrm::Setting[:hello] = false
    FatFreeCrm::Setting[:hello].should == false
    FatFreeCrm::Setting.hello.should == false
  end
end

