# == Schema Information
#
# Table name: opportunities
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  campaign_id     :integer
#  assigned_to     :integer
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  source          :string(32)
#  stage           :string(32)
#  probability     :integer
#  amount          :decimal(12, 2)
#  discount        :decimal(12, 2)
#  closes_on       :date
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe FatFreeCrm::Opportunity do

  before { login }

  it "should create a new instance given valid attributes" do
    FatFreeCrm::Opportunity.create!(:name => "Opportunity", :stage => 'analysis')
  end

  it "should be possible to create opportunity with the same name" do
    first  = FactoryGirl.create(:opportunity, :name => "Hello", :user => current_user)
    lambda { FactoryGirl.create(:opportunity, :name => "Hello", :user => current_user) }.should_not raise_error(ActiveRecord::RecordInvalid)
  end

  it "have a default stage" do
    FatFreeCrm::Setting.should_receive(:[]).with(:opportunity_default_stage).and_return('default')
    FatFreeCrm::Opportunity.default_stage.should eql('default')
  end

  it "have a fallback default stage" do
    FatFreeCrm::Opportunity.default_stage.should eql('prospecting')
  end

  describe "Update existing opportunity" do
    before(:each) do
      @account = FactoryGirl.create(:account)
      @opportunity = FactoryGirl.create(:opportunity, :account => @account)
    end

    it "should create new account if requested so" do
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :name => "New account" },
        :opportunity => { :name => "Hello" }
      })}.should change(FatFreeCrm::Account, :count).by(1)
      FatFreeCrm::Account.last.name.should == "New account"
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should update the account another account was selected" do
      @another_account = FactoryGirl.create(:account)
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :id => @another_account.id },
        :opportunity => { :name => "Hello" }
      })}.should_not change(FatFreeCrm::Account, :count)
      @opportunity.account.should == @another_account
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should drop existing Account if [create new account] is blank" do
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :name => "" },
        :opportunity => { :name => "Hello" }
      })}.should_not change(FatFreeCrm::Account, :count)
      @opportunity.account.should be_nil
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should drop existing Account if [-- None --] is selected from list of accounts" do
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :id => "" },
        :opportunity => { :name => "Hello" }
      })}.should_not change(FatFreeCrm::Account, :count)
      @opportunity.account.should be_nil
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should set the probability to 0% if opportunity has been lost" do
      opportunity = FactoryGirl.create(:opportunity, :stage => "prospecting", :probability => 25)
      opportunity.update_attributes(:stage => 'lost')
      opportunity.reload
      opportunity.probability.should == 0
    end

    it "should set the probablility to 100% if opportunity has been won" do
      opportunity = FactoryGirl.create(:opportunity, :stage => "prospecting", :probability => 65)
      opportunity.update_attributes(:stage => 'won')
      opportunity.reload
      opportunity.probability.should == 100
    end
  end

  describe "Scopes" do
    it "should find non-closed opportunities" do
      FatFreeCrm::Opportunity.delete_all
      @opportunities = [
        FactoryGirl.create(:opportunity, :stage => "prospecting", :amount => 1),
        FactoryGirl.create(:opportunity, :stage => "analysis", :amount => 1),
        FactoryGirl.create(:opportunity, :stage => "won",      :amount => 2),
        FactoryGirl.create(:opportunity, :stage => "won",      :amount => 2),
        FactoryGirl.create(:opportunity, :stage => "lost",     :amount => 3),
        FactoryGirl.create(:opportunity, :stage => "lost",     :amount => 3)
      ]
      FatFreeCrm::Opportunity.pipeline.sum(:amount).should ==  2
      FatFreeCrm::Opportunity.won.sum(:amount).should      ==  4
      FatFreeCrm::Opportunity.lost.sum(:amount).should     ==  6
      FatFreeCrm::Opportunity.sum(:amount).should          == 12
    end

    context "unassigned" do
      let(:unassigned_opportunity){ FactoryGirl.create(:opportunity, :assignee => nil)}
      let(:assigned_opportunity){ FactoryGirl.create(:opportunity, :assignee => FactoryGirl.create(:user))}

      it "includes unassigned opportunities" do
        FatFreeCrm::Opportunity.unassigned.should include(unassigned_opportunity)
      end

      it "does not include opportunities assigned to a user" do
        FatFreeCrm::Opportunity.unassigned.should_not include(assigned_opportunity)
      end
    end
  end

  describe "Attach" do
    before do
      @opportunity = FactoryGirl.create(:opportunity)
    end

    it "should return nil when attaching existing asset" do
      @task = FactoryGirl.create(:task, :asset => @opportunity, :user => current_user)
      @contact = FactoryGirl.create(:contact)
      @opportunity.contacts << @contact

      @opportunity.attach!(@task).should == nil
      @opportunity.attach!(@contact).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = FactoryGirl.create(:task, :user => current_user)
      @contact = FactoryGirl.create(:contact)

      @opportunity.attach!(@task).should == [ @task ]
      @opportunity.attach!(@contact).should == [ @contact ]
    end
  end

  describe "Discard" do
    before do
      @opportunity = FactoryGirl.create(:opportunity)
    end

    it "should discard a task" do
      @task = FactoryGirl.create(:task, :asset => @opportunity, :user => current_user)
      @opportunity.tasks.count.should == 1

      @opportunity.discard!(@task)
      @opportunity.reload.tasks.should == []
      @opportunity.tasks.count.should == 0
    end

    it "should discard an contact" do
      @contact = FactoryGirl.create(:contact)
      @opportunity.contacts << @contact
      @opportunity.contacts.count.should == 1

      @opportunity.discard!(@contact)
      @opportunity.contacts.should == []
      @opportunity.contacts.count.should == 0
    end
  end

  describe "Exportable" do
    describe "assigned opportunity" do
      before do
        FatFreeCrm::Opportunity.delete_all
        FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user))
        FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => FactoryGirl.create(:user, :first_name => nil, :last_name => nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { FatFreeCrm::Opportunity.all }
      end
    end

    describe "unassigned opportunity" do
      before do
        FatFreeCrm::Opportunity.delete_all
        FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user), :assignee => nil)
        FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { FatFreeCrm::Opportunity.all }
      end
    end
  end

  describe "permissions" do
    it_should_behave_like FatFreeCrm::Ability, FatFreeCrm::Opportunity
  end

  describe "scopes" do
    context "visible_on_dashboard" do
      before :each do
        @user = FactoryGirl.create(:user)
        @o1 = FactoryGirl.create(:opportunity_in_pipeline, :user => @user, :stage => 'prospecting')
        @o2 = FactoryGirl.create(:opportunity_in_pipeline, :user => @user, :assignee => FactoryGirl.create(:user), :stage => 'prospecting')
        @o3 = FactoryGirl.create(:opportunity_in_pipeline, :user => FactoryGirl.create(:user), :assignee => @user, :stage => 'prospecting')
        @o4 = FactoryGirl.create(:opportunity_in_pipeline, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user), :stage => 'prospecting')
        @o5 = FactoryGirl.create(:opportunity_in_pipeline, :user => FactoryGirl.create(:user), :assignee => @user, :stage => 'prospecting')
        @o6 = FactoryGirl.create(:opportunity, :assignee => @user, :stage => 'won')
        @o7 = FactoryGirl.create(:opportunity, :assignee => @user, :stage => 'lost')
      end

      it "should show opportunities which have been created by the user and are unassigned" do
        FatFreeCrm::Opportunity.visible_on_dashboard(@user).should include(@o1)
      end

      it "should show opportunities which are assigned to the user" do
        FatFreeCrm::Opportunity.visible_on_dashboard(@user).should include(@o3, @o5)
      end

      it "should not show opportunities which are not assigned to the user" do
        FatFreeCrm::Opportunity.visible_on_dashboard(@user).should_not include(@o4)
      end

      it "should not show opportunities which are created by the user but assigned" do
        FatFreeCrm::Opportunity.visible_on_dashboard(@user).should_not include(@o2)
      end

      it "does not include won or lost opportunities" do
        FatFreeCrm::Opportunity.visible_on_dashboard(@user).should_not include(@o6)
        FatFreeCrm::Opportunity.visible_on_dashboard(@user).should_not include(@o7)
      end
    end

    context "by_closes_on" do
      let(:o1) { FactoryGirl.create(:opportunity, :closes_on => 3.days.from_now) }
      let(:o2) { FactoryGirl.create(:opportunity, :closes_on => 7.days.from_now) }
      let(:o3) { FactoryGirl.create(:opportunity, :closes_on => 5.days.from_now) }

      it "should show opportunities ordered by closes on" do
        FatFreeCrm::Opportunity.by_closes_on.should == [o1, o3, o2]
      end
    end

    context "by_amount" do
      let(:o1) { FactoryGirl.create(:opportunity, :amount =>  50000) }
      let(:o2) { FactoryGirl.create(:opportunity, :amount =>  10000) }
      let(:o3) { FactoryGirl.create(:opportunity, :amount => 750000) }

      it "should show opportunities ordered by amount" do
        FatFreeCrm::Opportunity.by_amount.should == [o3, o1, o2]
      end
    end

    context "not lost" do
      let(:o1) { FactoryGirl.create(:opportunity, :stage => 'won') }
      let(:o2) { FactoryGirl.create(:opportunity, :stage => 'lost') }
      let(:o3) { FactoryGirl.create(:opportunity, :stage => 'analysis') }

      it "should show opportunities which are not lost" do
        FatFreeCrm::Opportunity.not_lost.should include(o1, o3)
      end

      it "should not show opportunities which are lost" do
        FatFreeCrm::Opportunity.not_lost.should_not include(o2)
      end
    end
  end
end
