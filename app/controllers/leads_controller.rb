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

class LeadsController < BaseController
  before_filter :get_data_for_sidebar, :only => :index

  # GET /leads/new
  #----------------------------------------------------------------------------
  def new
    super
    @users = User.except(@current_user)
    @campaigns = Campaign.my.order("name")
  end

  # GET /leads/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    super
    @users = User.except(@current_user)
    @campaigns = Campaign.my.order("name")
  end

  # POST /leads
  #----------------------------------------------------------------------------
  def create
    @asset = klass.new(params[asset_key])
    @users = User.except(@current_user)
    @campaigns = Campaign.my.order("name")

    if @asset.save_with_permissions(params)
      @assets = get_list_of_records
      if called_from_index_page?
        get_data_for_sidebar
      else
        get_data_for_sidebar(:campaign)
      end
    end
  end

  # PUT /leads/1
  #----------------------------------------------------------------------------
  def update
    @asset = klass.my.find(params[:id])

    if @asset.update_with_permissions(params[asset_key], params[:users])
      if called_from_index_page?
        get_data_for_sidebar
      else
        get_data_for_sidebar(:campaign)
      end
    else
      @users = User.except(@current_user)
      @campaigns = Campaign.my.order("name")
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # DELETE /leads/1
  #----------------------------------------------------------------------------
  # Handled by BaseController :destroy

  # GET /leads/1/convert
  #----------------------------------------------------------------------------
  def convert
    @lead = Lead.my.find(params[:id])
    @users = User.except(@current_user)
    @account = Account.new(:user => @current_user, :name => @lead.company, :access => "Lead")
    @accounts = Account.my.order("name")
    @opportunity = Opportunity.new(:user => @current_user, :access => "Lead", :stage => "prospecting", :campaign => @lead.campaign, :source => @lead.source)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Lead.my.find($1)
    end
    respond_with(@lead)

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js, :json, :xml) unless @lead
  end

  # PUT /leads/1/promote
  #----------------------------------------------------------------------------
  def promote
    @lead = Lead.my.find(params[:id])
    @users = User.except(@current_user)
    @account, @opportunity, @contact = @lead.promote(params)
    @accounts = Account.my.order("name")
    @stage = Setting.unroll(:opportunity_stage)

    respond_with(@lead) do |format|
      if @account.errors.empty? && @opportunity.errors.empty? && @contact.errors.empty?
        @lead.convert
        update_sidebar
      else
        format.json { render :json => @account.errors + @opportunity.errors + @contact.errors, :status => :unprocessable_entity }
        format.xml  { render :xml => @account.errors + @opportunity.errors + @contact.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # PUT /leads/1/reject
  #----------------------------------------------------------------------------
  def reject
    @lead = Lead.my.find(params[:id])
    @lead.reject if @lead
    update_sidebar

    respond_with(@lead) do |format|
      format.html { flash[:notice] = t(:msg_asset_rejected, @lead.full_name); redirect_to leads_path }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end

  # DELETE /leads/1
  #----------------------------------------------------------------------------
  def destroy
    super  # BaseController :destroy

    if called_from_landing_page?(:campaigns)
      @campaign = @lead.campaign # Reload lead's campaign if any.
    end
  end

  # PUT /leads/1/attach
  #----------------------------------------------------------------------------
  # Handled by BaseController :attach

  # POST /leads/1/discard
  #----------------------------------------------------------------------------
  # Handled by BaseController :discard

  # POST /leads/auto_complete/query                                        AJAX
  #----------------------------------------------------------------------------
  # Handled by BaseController :auto_complete

  # GET /leads/options                                                     AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:leads_per_page] || Lead.per_page
      @outline  = @current_user.pref[:leads_outline]  || Lead.outline
      @sort_by  = @current_user.pref[:leads_sort_by]  || Lead.sort_by
      @naming   = @current_user.pref[:leads_naming]   || Lead.first_name_position
    end
  end

  # POST /leads/redraw                                                     AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:leads_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:leads_outline]  = params[:outline]  if params[:outline]

    # Sorting and naming only: set the same option for Contacts if the hasn't been set yet.
    if params[:sort_by]
      @current_user.pref[:leads_sort_by] = Lead::sort_by_map[params[:sort_by]]
      if Contact::sort_by_fields.include?(params[:sort_by])
        @current_user.pref[:contacts_sort_by] ||= Contact::sort_by_map[params[:sort_by]]
      end
    end
    if params[:naming]
      @current_user.pref[:leads_naming] = params[:naming]
      @current_user.pref[:contacts_naming] ||= params[:naming]
    end

    @leads = get_leads(:page => 1) # Start one the first page.
    render :index
  end

  # POST /leads/filter                                                     AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_lead_status] = params[:status]
    @leads = get_leads(:page => 1) # Start one the first page.
    render :index
  end

  protected
  #----------------------------------------------------------------------------
  def get_list_of_records(options = {})
    super(options.merge(:filter => :filter_by_lead_status))
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar(related = false)
    if related
      instance_variable_set("@#{related}", @asset.send(related)) if called_from_landing_page?(related.to_s.pluralize)
    else
      @lead_status_total = { :all => Lead.my.count, :other => 0 }
      Setting.lead_status.each do |key|
        @lead_status_total[key] = Lead.my.where(:status => key.to_s).count
        @lead_status_total[:other] -= @lead_status_total[key]
      end
      @lead_status_total[:other] += @lead_status_total[:all]
    end
  end
end
