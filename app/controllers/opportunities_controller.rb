# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class OpportunitiesController < BaseController
  before_filter :load_settings
  before_filter :get_data_for_sidebar, :only => :index
  before_filter :set_params, :only => [:index, :redraw, :filter]

  # GET /opportunities/new
  #----------------------------------------------------------------------------
  def new
    super
    @asset = Opportunity.new(:user => @current_user, :stage => "prospecting", :access => Setting.default_access)
    @users       = User.except(@current_user)
    @account     = @asset.account || Account.new(:user => @current_user)
    @accounts    = Account.my.order("name")
  end

  # GET /opportunities/1/edit                                              AJAX
  #----------------------------------------------------------------------------
  def edit
    super
    @users = User.except(@current_user)
    @account  = @asset.account || Account.new(:user => @current_user)
    @accounts = Account.my.order("name")
  end

  # POST /opportunities
  #----------------------------------------------------------------------------
  def create
    @asset = klass.new(params[asset_key])

    if @asset.save_with_account_and_permissions(params)
      @assets = get_list_of_records
      if called_from_index_page?
        get_data_for_sidebar
      elsif called_from_landing_page?(:accounts)
        get_data_for_sidebar(:account)
      elsif called_from_landing_page?(:campaigns)
        get_data_for_sidebar(:campaign)
      end
    else
      @users = User.except(@current_user)
      @accounts = Account.my.order("name")
      unless params[:account][:id].blank?
        @account = Account.find(params[:account][:id])
      else
        if request.referer =~ /\/accounts\/(.+)$/
          @account = Account.find($1) # related account
        else
          @account = Account.new(:user => @current_user)
        end
      end
      @contact = Contact.find(params[:contact]) unless params[:contact].blank?
      @campaign = Campaign.find(params[:campaign]) unless params[:campaign].blank?
    end
  end

  # PUT /opportunities/1
  #----------------------------------------------------------------------------
  def update
    @asset = klass.my.find(params[:id])

    if @asset.update_with_account_and_permissions(params)
      if called_from_index_page?
        get_data_for_sidebar
      elsif called_from_landing_page?(:accounts)
        get_data_for_sidebar(:account)
      elsif called_from_landing_page?(:campaigns)
        get_data_for_sidebar(:campaign)
      end
    else
      @users = User.except(@current_user)
      @accounts = Account.my.order("name")
      @account = @asset.account || Account.new(:user => @current_user)
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # DELETE /opportunities/1
  #----------------------------------------------------------------------------
  def destroy
    super  # BaseController :destroy

    if called_from_landing_page?(:accounts)
      @account = @opportunity.account   # Reload related account if any.
    elsif called_from_landing_page?(:campaigns)
      @campaign = @opportunity.campaign # Reload related campaign if any.
    end
  end

  # PUT /opportunities/1/attach
  #----------------------------------------------------------------------------
  # Handled by BaseController :attach

  # POST /opportunities/1/discard
  #----------------------------------------------------------------------------
  # Handled by BaseController :discard

  # POST /opportunities/auto_complete/query                                AJAX
  #----------------------------------------------------------------------------
  # Handled by BaseController :auto_complete

  # GET /opportunities/options                                             AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:opportunities_per_page] || Opportunity.per_page
      @outline  = @current_user.pref[:opportunities_outline]  || Opportunity.outline
      @sort_by  = @current_user.pref[:opportunities_sort_by]  || Opportunity.sort_by
    end
  end

  # GET /opportunities/contacts                                            AJAX
  #----------------------------------------------------------------------------
  def contacts
    @opportunity = Opportunity.my.find(params[:id])
  end

  # POST /opportunities/redraw                                             AJAX
  #----------------------------------------------------------------------------
  def redraw
    @opportunities = get_opportunities(:page => 1)
    render :index
  end

  # POST /opportunities/filter                                             AJAX
  #----------------------------------------------------------------------------
  def filter
    @opportunities = get_opportunities(:page => 1)
    render :index
  end

  protected
  #----------------------------------------------------------------------------
  def get_list_of_records(options = {})
    super(options.merge(:filter => :filter_by_opportunity_stage))
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar(related = false)
    if related
      instance_variable_set("@#{related}", @asset.send(related)) if called_from_landing_page?(related.to_s.pluralize)
    else
      @opportunity_stage_total = { :all => Opportunity.my.count, :other => 0 }
      @stage.each do |value, key|
        @opportunity_stage_total[key] = Opportunity.my.where(:stage => key.to_s).count
        @opportunity_stage_total[:other] -= @opportunity_stage_total[key]
      end
      @opportunity_stage_total[:other] += @opportunity_stage_total[:all]
    end
  end

  #----------------------------------------------------------------------------
  def load_settings
    @stage = Setting.unroll(:opportunity_stage)
  end

  def set_params
    @current_user.pref[:opportunities_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:opportunities_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:opportunities_sort_by]  = Opportunity::sort_by_map[params[:sort_by]] if params[:sort_by]
    session[:filter_by_opportunity_stage] = params[:stage] if params[:stage]
  end
end
