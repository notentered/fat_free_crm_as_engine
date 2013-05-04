require 'spec_helper'

describe FatFreeCrm::ApplicationController do

  describe "auto_complete_ids_to_exclude" do

    it "should return [] when related is nil" do
      controller.send(:auto_complete_ids_to_exclude, nil).should == []
    end

    it "should return [] when related is ''" do
      controller.send(:auto_complete_ids_to_exclude, '').should == []
    end

    it "should return campaign id 5 when related is '5' and controller is campaigns" do
      controller.send(:auto_complete_ids_to_exclude, '5').sort.should == [5]
    end

    it "should return [6, 9] when related is 'campaigns/7'" do
      controller.stub!(:controller_name).and_return('opportunities')
      campaign = mock(FatFreeCrm::Campaign, :opportunities => [mock(:id => 6), mock(:id => 9)])
      FatFreeCrm::Campaign.should_receive(:find_by_id).with('7').and_return(campaign)
      controller.send(:auto_complete_ids_to_exclude, 'campaigns/7').sort.should == [6, 9]
    end

    it "should return [] when related object is not found" do
      FatFreeCrm::Campaign.should_receive(:find_by_id).with('7').and_return(nil)
      controller.send(:auto_complete_ids_to_exclude, 'campaigns/7').should == []
    end

    it "should return [] when related object association is not found" do
      controller.stub!(:controller_name).and_return('not_a_method_that_exists')
      campaign = mock(FatFreeCrm::Campaign)
      FatFreeCrm::Campaign.should_receive(:find_by_id).with('7').and_return(campaign)
      controller.send(:auto_complete_ids_to_exclude, 'campaigns/7').should == []
    end

  end

end
