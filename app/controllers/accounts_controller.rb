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

class AccountsController < BaseController
  before_filter :get_data_for_sidebar, :only => :index

  # GET /accounts/new
  #----------------------------------------------------------------------------
  def new
    super
    @users = User.except(@current_user)
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    super
    @users = User.except(@current_user)
  end

  # POST /accounts                                                         AJAX
  #----------------------------------------------------------------------------
  def create
    super
    @users = User.except(@current_user)
  end

  # PUT /accounts/1
  #----------------------------------------------------------------------------
  # Handled by BaseController :update

  # DELETE /accounts/1
  #----------------------------------------------------------------------------
  # Handled by BaseController :destroy

  # PUT /accounts/1/attach
  #----------------------------------------------------------------------------
  # Handled by BaseController :attach

  # PUT /accounts/1/discard
  #----------------------------------------------------------------------------
  # Handled by BaseController :discard

  # POST /accounts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by BaseController :auto_complete

  # GET /accounts/options                                                  AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:accounts_per_page] || Account.per_page
      @outline  = @current_user.pref[:accounts_outline]  || Account.outline
      @sort_by  = @current_user.pref[:accounts_sort_by]  || Account.sort_by
    end
  end

  # POST /accounts/redraw                                                  AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:accounts_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:accounts_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:accounts_sort_by]  = Account::sort_by_map[params[:sort_by]] if params[:sort_by]
    @accounts = get_accounts(:page => 1)
    render :index
  end

  # GET /accounts/contacts                                                 AJAX
  #----------------------------------------------------------------------------
  def contacts
    @account = Account.my.find(params[:id])
  end

  # GET /accounts/opportunities                                            AJAX
  #----------------------------------------------------------------------------
  def opportunities
    @account = Account.my.find(params[:id])
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_account_category] = params[:category]
    @accounts = get_accounts(:page => 1)
    render :index
  end

  protected
  #----------------------------------------------------------------------------
  def get_list_of_records(options = {})
    super(options.merge(:filter => :filter_by_account_category))
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @account_category_total = Hash[
      Setting.account_category.map do |key|
        [ key, Account.my.where(:category => key.to_s).count ]
      end
    ]
    categorized = @account_category_total.values.sum
    @account_category_total[:all] = Account.my.count
    @account_category_total[:other] = @account_category_total[:all] - categorized
  end
end
