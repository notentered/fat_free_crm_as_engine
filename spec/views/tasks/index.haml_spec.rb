require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tasks/index" do
  include FatFreeCrm::TasksHelper

  before do
    login_and_assign
  end

  TASK_STATUSES.each do |status|
    before do
      user = FactoryGirl.create(:user)
      account = FactoryGirl.create(:account)
      @due  = FactoryGirl.create(:task, :asset => account, :bucket => "due_asap", :assignee => user)
      @completed = FactoryGirl.create(:task, :asset => account, :bucket => "completed_today", :assignee => user, :completed_at => 1.hour.ago, :completor => user)
    end

    it "should render list of #{status} tasks if list of tasks is not empty" do
      assign(:view, status)
      assign(:tasks, { :due_asap => [ @due ], :completed_today => [ @completed ] })

      render

      view.should render_template(:partial => "_" << status, :count => 1)
      view.should_not render_template(:partial => "_empty")
    end
  end

  TASK_STATUSES.each do |status|
    it "should render a message if there're no #{status} tasks" do
      assign(:view, status)
      assign(:tasks, { :due_asap => [], :due_today => [] })

      render

      view.should render_template(:partial => "_empty")
    end
  end
end

