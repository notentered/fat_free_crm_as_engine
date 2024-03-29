require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/opportunities/index" do
  include FatFreeCrm::OpportunitiesHelper

  before do
    login_and_assign
    view.lookup_context.prefixes << 'entities'
    assign :stage, FatFreeCrm::Setting.unroll(:opportunity_stage)
    assign :per_page, FatFreeCrm::Opportunity.per_page
    assign :sort_by,  FatFreeCrm::Opportunity.sort_by
    assign :ransack_search, FatFreeCrm::Opportunity.search
  end

  it "should render list of accounts if list of opportunities is not empty" do
    assign(:opportunities, [ FactoryGirl.create(:opportunity) ].paginate)

    render
    view.should render_template(:partial => "_opportunity")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end

  it "should render a message if there're no opportunities" do
    assign(:opportunities, [].paginate)

    render
    view.should_not render_template(:partial => "_opportunities")
    view.should render_template(:partial => "shared/_empty")
    view.should render_template(:partial => "shared/_paginate_with_per_page")
  end

end
