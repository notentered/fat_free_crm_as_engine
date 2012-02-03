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

class CampaignsController < BaseController
  before_filter :get_data_for_sidebar, :only => :index

  # GET /campaigns/new
  # GET /campaigns/new.json
  # GET /campaigns/new.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def new
    super
    @users = User.except(@current_user)
  end

  # GET /campaigns/1/edit                                                  AJAX
  #----------------------------------------------------------------------------
  def edit
    super
    @users = User.except(@current_user)
  end

  # GET /campaigns/1                                                       AJAX
  #----------------------------------------------------------------------------
  def show
    @stage = Setting.unroll(:opportunity_stage)
    super
  end

  # POST /campaign                                                         AJAX
  #----------------------------------------------------------------------------
  def create
    super
    @users = User.except(@current_user)
  end

  # PUT /campaigns/1
  #----------------------------------------------------------------------------
  # Handled by BaseController :update

  # DELETE /campaigns/1
  #----------------------------------------------------------------------------
  # Handled by BaseController :destroy

  # PUT /campaigns/1/attach
  #----------------------------------------------------------------------------
  # Handled by BaseController :attach

  # PUT /campaigns/1/discard
  #----------------------------------------------------------------------------
  # Handled by BaseController :discard

  # POST /campaigns/auto_complete/query                                    AJAX
  #----------------------------------------------------------------------------
  # Handled by BaseController :auto_complete

  # GET /campaigns/options                                                 AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:campaigns_per_page] || Campaign.per_page
      @outline  = @current_user.pref[:campaigns_outline]  || Campaign.outline
      @sort_by  = @current_user.pref[:campaigns_sort_by]  || Campaign.sort_by
    end
  end

  # GET /accounts/leads                                                    AJAX
  #----------------------------------------------------------------------------
  def leads
    @campaign = Campaign.my.find(params[:id])
  end

  # GET /accounts/opportunities                                            AJAX
  #----------------------------------------------------------------------------
  def opportunities
    @campaign = Campaign.my.find(params[:id])
  end

  # POST /campaigns/redraw                                                 AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:campaigns_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:campaigns_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:campaigns_sort_by]  = Campaign::sort_by_map[params[:sort_by]] if params[:sort_by]
    @assets = get_list_of_records(:page => 1)
    render :index
  end

  # POST /campaigns/filter                                                 AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_campaign_status] = params[:status]
    @assets = get_list_of_records(:page => 1)
    render :index
  end

  protected
  #----------------------------------------------------------------------------
  def get_list_of_records(options = {})
    super(options.merge(:filter => :filter_by_campaign_status))
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @campaign_status_total = { :all => Campaign.my.count, :other => 0 }
    Setting.campaign_status.each do |key|
      @campaign_status_total[key] = Campaign.my.where(:status => key.to_s).count
      @campaign_status_total[:other] -= @campaign_status_total[key]
    end
    @campaign_status_total[:other] += @campaign_status_total[:all]
  end
end
