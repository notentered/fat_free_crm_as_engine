require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/destroy" do
  include FatFreeCrm::AccountsHelper

  before do
    login_and_assign
    assign(:account, @account = FactoryGirl.create(:account))
    assign(:accounts, [ @account ].paginate)
    assign(:account_category_total, Hash.new(1))
    render
  end

  it "should blind up destroyed account partial" do
    rendered.should include(%Q/$("account_#{@account.id}").visualEffect("blind_up"/)
  end

  it "should update accounts pagination" do
    rendered.should have_rjs("paginate")
  end

  it "should update accounts sidebar" do
    rendered.should have_rjs("sidebar") do |rjs|
      with_tag("div[id=filters]")
      with_tag("div[id=recently]")
    end
  end

end

