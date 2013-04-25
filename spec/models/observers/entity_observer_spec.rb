require 'spec_helper'

describe FatFreeCrm::EntityObserver do
  [:account, :contact, :lead, :opportunity].each do |entity_type|
    describe "on creation of #{entity_type}" do
      let(:assignee) { FactoryGirl.create(:user) }
      let(:assigner) { FactoryGirl.create(:user) }
      let!(:entity)  { FactoryGirl.build(entity_type, :user => assigner, :assignee => assignee) }
      let(:mail) { mock('mail', :deliver => true) }

      before :each do
        PaperTrail.stub(:whodunnit).and_return(assigner)
      end

      after :each do
        entity.save
      end

      it "sends notification to the assigned user for entity" do
        FatFreeCrm::UserMailer.should_receive(:assigned_entity_notification).with(entity, assigner).and_return(mail)
      end

      it "does not notify anyone if the entity is created and assigned to no-one" do
        entity.assignee = nil
        FatFreeCrm::UserMailer.should_not_receive(:assigned_entity_notification)
      end

      it "does not notify me if I have created an entity for myself" do
        entity.assignee = entity.user = assigner
        FatFreeCrm::UserMailer.should_not_receive(:assigned_entity_notification)
      end
    end

    describe "on update of #{entity_type}" do
      let(:assignee) { FactoryGirl.create(:user) }
      let(:assigner) { FactoryGirl.create(:user) }
      let!(:entity)  { FactoryGirl.create(entity_type, :user => FactoryGirl.create(:user)) }
      let(:mail) { mock('mail', :deliver => true) }

      before :each do
        PaperTrail.stub(:whodunnit).and_return(assigner)
      end

      it "notifies the new owner if the entity is re-assigned" do
        FatFreeCrm::UserMailer.should_receive(:assigned_entity_notification).with(entity, assigner).and_return(mail)
        entity.update_attributes(:assignee => assignee)
      end

      it "does not notify the owner if the entity is not re-assigned" do
        FatFreeCrm::UserMailer.should_not_receive(:assigned_entity_notification)
        entity.touch
      end

      it "does not notify anyone if the entity becomes unassigned" do
        FatFreeCrm::UserMailer.should_not_receive(:assigned_entity_notification)
        entity.update_attributes(:assignee => nil)
      end

      it "does not notify me if I re-assign an entity to myself" do
        FatFreeCrm::UserMailer.should_not_receive(:assigned_entity_notification)
        entity.update_attributes(:assignee => assigner)
      end
    end
  end
end
