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

class FatFreeCrm::ContactsController < FatFreeCrm::EntitiesController
  before_filter :get_accounts, :only => [ :new, :create, :edit, :update ]

  # GET /contacts
  #----------------------------------------------------------------------------
  def index
    @contacts = get_contacts(:page => params[:page], :per_page => params[:per_page])

    respond_with @contacts do |format|
      format.xls { render :layout => 'header' }
      format.csv { render :csv => @contacts }
    end
  end

  # GET /contacts/1
  # AJAX /contacts/1
  #----------------------------------------------------------------------------
  def show
    @stage = FatFreeCrm::Setting.unroll(:opportunity_stage)
    @comment = FatFreeCrm::Comment.new
    @timeline = timeline(@contact)
    respond_with(@contact)
  end

  # GET /contacts/new
  #----------------------------------------------------------------------------
  def new
    @contact.attributes = {:user => current_user, :access => FatFreeCrm::Setting.default_access, :assigned_to => nil}
    @account = FatFreeCrm::Account.new(:user => current_user)

    if params[:related]
      model, id = params[:related].split('_')
      if related = "FatFreeCrm::#{model.classify}".constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) and return
      end
    end

    respond_with(@contact)
  end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @account = @contact.account || FatFreeCrm::Account.new(:user => current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = FatFreeCrm::Contact.my.find_by_id($1) || $1.to_i
    end

    respond_with(@contact)
  end

  # POST /contacts
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    respond_with(@contact) do |format|
      if @contact.save_with_account_and_permissions(params)
        @contact.add_comment_by_user(@comment_body, current_user)
        @contacts = get_contacts if called_from_index_page?
      else
        unless params[:account][:id].blank?
          @account = FatFreeCrm::Account.find(params[:account][:id])
        else
          if request.referer =~ /\/accounts\/(.+)$/
            @account = FatFreeCrm::Account.find($1) # related account
          else
            @account = FatFreeCrm::Account.new(:user => current_user)
          end
        end
        @opportunity = FatFreeCrm::Opportunity.my.find(params[:opportunity]) unless params[:opportunity].blank?
      end
    end
  end

  # PUT /contacts/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@contact) do |format|
      unless @contact.update_with_account_and_permissions(params)
        if @contact.account
          @account = FatFreeCrm::Account.find(@contact.account.id)
        else
          @account = FatFreeCrm::Account.new(:user => current_user)
        end
      end
    end
  end

  # DELETE /contacts/1
  #----------------------------------------------------------------------------
  def destroy
    @contact.destroy

    respond_with(@contact) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /contacts/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # POST /contacts/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /contacts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # POST /contacts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:contacts_per_page] = params[:per_page] if params[:per_page]

    # Sorting and naming only: set the same option for Leads if the hasn't been set yet.
    if params[:sort_by]
      current_user.pref[:contacts_sort_by] = FatFreeCrm::Contact::sort_by_map[params[:sort_by]]
      if FatFreeCrm::Lead::sort_by_fields.include?(params[:sort_by])
        current_user.pref[:leads_sort_by] ||= FatFreeCrm::Lead::sort_by_map[params[:sort_by]]
      end
    end
    if params[:naming]
      current_user.pref[:contacts_naming] = params[:naming]
      current_user.pref[:leads_naming] ||= params[:naming]
    end

    @contacts = get_contacts(:page => 1, :per_page => params[:per_page]) # Start on the first page.
    set_options # Refresh options
    
    respond_with(@contacts) do |format|
      format.js { render :index }
    end
  end

  private
  #----------------------------------------------------------------------------
  alias :get_contacts :get_list_of_records

  #----------------------------------------------------------------------------
  def get_accounts
    @accounts = FatFreeCrm::Account.my.order('name')
  end

  def set_options
    super
    @naming = (current_user.pref[:contacts_naming]   || FatFreeCrm::Contact.first_name_position) unless params[:cancel].true?
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        @contacts = get_contacts
        if @contacts.blank?
          @contacts = get_contacts(:page => current_page - 1) if current_page > 1
          render :index and return
        end
      else
        self.current_page = 1
      end
      # At this point render destroy.js.rjs
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @contact.full_name)
      redirect_to contacts_path
    end
  end
end