require 'spec_helper'

describe FatFreeCrm::List do
  it "should parse the controller from the url" do
    ["/controller/action", "controller/action?utf8=%E2%9C%93"].each do |url|
      list = FactoryGirl.build(:list, :url => url)
      list.controller.should == "controller"
    end
    list = FactoryGirl.build(:list, :url => nil)
    list.controller.should == nil
  end
end
