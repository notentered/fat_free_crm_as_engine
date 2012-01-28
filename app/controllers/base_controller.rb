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

# This controller handles logic for the five base models:
# => Contact, Lead, Account, Campaign, Opportunity

class BaseController < ApplicationController
  inherit_resources

  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  after_filter  :update_recently_viewed, :only => :show

  respond_to :html, :only => [ :index, :show, :auto_complete ]
  respond_to :js
  respond_to :json, :xml, :except => :edit
  respond_to :atom, :csv, :rss, :xls, :only => :index

  # Common controller actions
  #----------------------------------------------------------------------------

  # GET /*/1
  #----------------------------------------------------------------------------
  def show
    @asset = klass.my.find(params[:id])
    @comment = Comment.new
    @timeline = timeline(@asset)
  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :json, :xml)
  end

  # GET /*/new
  #----------------------------------------------------------------------------
  def new
    @asset ||= klass.new(:user => current_user, :access => Setting.default_access)
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.my.find(id))
    end
  rescue ActiveRecord::RecordNotFound # Kicks in if related asset was not found.
    respond_to_related_not_found(model, :js) if model
  end

  # GET /*/1/edit                                                          AJAX
  #----------------------------------------------------------------------------
  def edit
    @asset = klass.my.find(params[:id])
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = klass.my.find($1)
    end
  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @asset
  end

  # POST /*
  #----------------------------------------------------------------------------
  def create
    @asset = klass.new(params[asset_key])
    if @asset.save_with_permissions(params[:users])
      @assets = get_list_of_records
      get_data_for_sidebar if respond_to?(:get_data_for_sidebar)
    end
  end

  # PUT /*/1
  #----------------------------------------------------------------------------
  def update
    @asset = klass.my.find(params[:id])
    if @asset.update_with_permissions(params[asset_key], params[:users])
      get_data_for_sidebar
    else
      @users = User.except(@current_user) # Need it to redraw edit form.
    end
  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # DELETE /*/1
  #----------------------------------------------------------------------------
  def destroy
    if @asset = klass.my.find(params[:id])
      @asset.destroy
    end

    respond_with(@asset) do |format|
      format.js do
        if called_from_landing_page?(:campaigns)
          @campaign = @asset.campaign               # Reload asset's campaign if any.
        elsif called_from_index_page?                  # Called from index.
          # Get data for the sidebar, if available
          get_data_for_sidebar if respond_to?(:get_data_for_sidebar)
          @assets = get_list_of_records             # Get assets for current page.
          if @assets.blank?                         # If no asset on this page then try the previous one.
            @assets = get_list_of_records(:page => current_page - 1) if current_page > 1
            render :index                           # And reload the whole list even if it's empty.
          end
        else                                        # Called from related asset.
          self.current_page = 1                     # Reset current page to 1 to make sure it stays valid.
          # Render destroy.js.rjs
        end
      end

      format.html do
        self.current_page = 1
        asset_name = @asset.respond_to?(:full_name) ? @asset.full_name : @asset.name
        flash[:notice] = t(:msg_asset_deleted, asset_name)
        redirect_to url_for
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end


  # Common auto_complete handler for all core controllers.
  #----------------------------------------------------------------------------
  def auto_complete
    @query = params[:auto_complete_query]
    @auto_complete = hook(:auto_complete, self, :query => @query, :user => @current_user)
    if @auto_complete.empty?
      @auto_complete = klass.my.search(@query).limit(10)
    else
      @auto_complete = @auto_complete.last
    end
    session[:auto_complete] = controller_name.to_sym
    render "shared/auto_complete", :layout => nil
  end

  # Common attach handler for all core controllers.
  #----------------------------------------------------------------------------
  def attach
    @asset = klass.my.find(params[:id])
    @attachment = params[:assets].classify.constantize.find(params[:asset_id])
    @attached = @asset.attach!(@attachment)
    @asset = @asset.reload

    respond_to do |format|
      format.js   { render "shared/attach" }
      format.json { render :json => model.reload }
      format.xml  { render :xml => model.reload }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end

  # Common discard handler for all core controllers.
  #----------------------------------------------------------------------------
  def discard
    @asset = klass.my.find(params[:id])
    @attachment = params[:attachment].constantize.find(params[:attachment_id])
    @asset.discard!(@attachment)
    @asset = @asset.reload

    respond_to do |format|
      format.js   { render "shared/discard" }
      format.json { render :json => model.reload }
      format.xml  { render :xml => model.reload }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end

  def timeline(asset)
    (asset.comments + asset.emails).sort { |x, y| y.created_at <=> x.created_at }
  end

  # Controller instance method that responds to /controlled/tagged/tag request.
  # It stores given tag as current query and redirect to index to display all
  # records tagged with the tag.
  #----------------------------------------------------------------------------
  def tagged
    self.send(:current_query=, "#" << params[:id]) unless params[:id].blank?
    redirect_to :action => "index"
  end

  def field_group
    if @tag = Tag.find_by_name(params[:tag].strip) and
       @field_group = FieldGroup.find_by_tag_id(@tag.id)

      @asset = klass.find_by_id(params[:asset_id]) || klass.new

      render 'fields/group'
    else
      render :text => ''
    end
  end

  protected
  #----------------------------------------------------------------------------
  def collection
    @assets ||= get_list_of_records(:page => params[:page])
  end

  # Get list of records for a given model class.
  #----------------------------------------------------------------------------
  def get_list_of_records(options = {})
    items = klass.name.tableize
    options[:query] ||= params[:query]                        if params[:query]
    self.current_page = options[:page]                        if options[:page]
    query, tags       = parse_query_and_tags(options[:query]) if options[:query]
    self.current_query = query

    records = {
      :user  => current_user,
      :order => current_user.pref[:"#{items}_sort_by"] || klass.sort_by
    }
    pages = {
      :page     => current_page,
      :per_page => current_user.pref[:"#{items}_per_page"]
    }

    # Call the hook and return its output if any.
    assets = hook(:"get_#{items}", self, :records => records, :pages => pages)
    return assets.last unless assets.empty?

    # Use default processing if no hooks are present. Note that comma-delimited
    # export includes deleted records, and the pagination is enabled only for
    # plain HTTP, Ajax and XML API requests.
    wants = request.format
    filter = session[options[:filter]].to_s.split(',') if options[:filter]

    scope = klass.my(records)
    scope = scope.state(filter)                   if filter.present?
    scope = scope.search(query)                   if query.present?
    scope = scope.tagged_with(tags, :on => :tags) if tags.present?
    scope = scope.unscoped                        if wants.csv?
    scope = scope.paginate(pages)                 if wants.html? || wants.js? || wants.xml?
    scope
  end
end
