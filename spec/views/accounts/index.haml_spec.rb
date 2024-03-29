require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index" do
  include FatFreeCrm::AccountsHelper

  before do
    view.lookup_context.prefixes << 'entities'
    assign :per_page, FatFreeCrm::Account.per_page
    assign :sort_by,  FatFreeCrm::Account.sort_by
    assign :ransack_search, FatFreeCrm::Account.search
    login_and_assign
  end

  it "should render account name" do
    assign(:accounts, [ FactoryGirl.create(:account, :name => 'New Media Inc'), FactoryGirl.create(:account) ].paginate)
    render
    rendered.should have_tag('a', :text => "New Media Inc")
  end

  it "should render list of accounts if list of accounts is not empty" do
    assign(:accounts, [ FactoryGirl.create(:account), FactoryGirl.create(:account) ].paginate)

    render
    view.should render_template(:partial => "_account")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end

  it "should render a message if there're no accounts" do
    assign(:accounts, [].paginate)

    render
    view.should_not render_template(:partial => "_account")
    view.should render_template(:partial => "shared/_empty")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end
end
