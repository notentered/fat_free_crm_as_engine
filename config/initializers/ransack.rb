Ransack.configure do |config|
  config.default_predicates = {
    :compounds => true,
    :only => [
      :cont, :not_cont, :blank, :present, :true, :false, :eq, :not_eq,
      :lt, :gt, :null, :not_null, :matches, :does_not_match
    ]
  }

  config.ajax_options = {
    :url  => '/:controller/auto_complete.json',
    :type => 'POST',
    :key  => 'auto_complete_query'
  }
end

# CODE SMELL: Monkey patch Ransack-UI to work with namespaces
# ToDo: Consider fix it Ransack-UI
module RansackUI
  module ControllerHelpers
    def load_ransack_search(klass = nil)
      klass ||= controller_path.classify.constantize
      @ransack_search = klass.search(params[:q])
      @ransack_search.build_grouping if @ransack_search.groupings.empty?
      @ransack_search
    end
  end
end