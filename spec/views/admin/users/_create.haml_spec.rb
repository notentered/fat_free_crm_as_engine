require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/_new" do
  before do
    login_and_assign(:admin => true)
    assign(:user, FatFreeCrm::User.new)
    assign(:users, [ current_user ])
  end

  it "renders [Create User] form" do
    render
    view.should render_template(:partial => "admin/users/_profile")

    rendered.should have_tag("form[class=new_user]")
  end
end
