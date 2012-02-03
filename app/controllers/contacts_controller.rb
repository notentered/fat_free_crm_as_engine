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

class ContactsController < BaseController
  before_filter :get_users, :only => [ :new, :create, :edit, :update ]
  before_filter :get_accounts, :only => [ :new, :create, :edit, :update ]

  # GET /contacts/new
  #----------------------------------------------------------------------------
  def new
    super
    @account ||= @asset.account || Account.new(:user => current_user) if @asset
  end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    super
    @account  = @asset.account || Account.new(:user => current_user) if @asset
  end

  # GET /contacts/1                                                        AJAX
  #----------------------------------------------------------------------------
  def show
    @stage = Setting.unroll(:opportunity_stage)
    super
  end

  # POST /contacts
  #----------------------------------------------------------------------------
  def create
    @asset = klass.new(params[asset_key])

    if @asset.save_with_account_and_permissions(params)
      @assets = get_list_of_records
    else
      unless params[:account][:id].blank?
        @account = Account.find(params[:account][:id])
      else
        if request.referer =~ /\/accounts\/(.+)$/
          @account = Account.find($1) # related account
        else
          @account = Account.new(:user => current_user)
        end
      end
      @opportunity = Opportunity.find(params[:opportunity]) unless params[:opportunity].blank?
    end
  end

  # PUT /contacts/1
  #----------------------------------------------------------------------------
  def update
    @asset = klass.my.find(params[:id])

    unless @asset.update_with_account_and_permissions(params)
      @users = User.except(current_user)
      @account = @asset.account || Account.new(:user => current_user)
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # DELETE /contacts/1
  #----------------------------------------------------------------------------
  # Handled by BaseController :destroy

  # PUT /contacts/1/attach
  #----------------------------------------------------------------------------
  # Handled by BaseController :attach

  # POST /contacts/1/discard
  #----------------------------------------------------------------------------
  # Handled by BaseController :discard

  # POST /contacts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by BaseController :auto_complete

  # GET /contacts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = current_user.pref[:contacts_per_page] || Contact.per_page
      @outline  = current_user.pref[:contacts_outline]  || Contact.outline
      @sort_by  = current_user.pref[:contacts_sort_by]  || Contact.sort_by
      @naming   = current_user.pref[:contacts_naming]   || Contact.first_name_position
    end
  end

  # GET /contacts/opportunities                                            AJAX
  #----------------------------------------------------------------------------
  def opportunities
    @contact = Contact.my.find(params[:id])
  end

  # POST /contacts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:contacts_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:contacts_outline]  = params[:outline]  if params[:outline]

    # Sorting and naming only: set the same option for Leads if the hasn't been set yet.
    if params[:sort_by]
      current_user.pref[:contacts_sort_by] = Contact::sort_by_map[params[:sort_by]]
      if Lead::sort_by_fields.include?(params[:sort_by])
        current_user.pref[:leads_sort_by] ||= Lead::sort_by_map[params[:sort_by]]
      end
    end
    if params[:naming]
      current_user.pref[:contacts_naming] = params[:naming]
      current_user.pref[:leads_naming] ||= params[:naming]
    end

    @assets = get_list_of_records(:page => 1) # Start on the first page.
    render :index
  end

  protected
  #----------------------------------------------------------------------------

  def get_accounts
    @accounts = Account.my.order("name")
  end
end
