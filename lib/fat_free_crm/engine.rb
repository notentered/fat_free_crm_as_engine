module FatFreeCRM
  class Engine < Rails::Engine
    config.autoload_paths += Dir[root.join("app/models/**")]
    
    config.to_prepare do
      %w(is_paranoid country_select dynamic_form gravatar_image_tag responds_to_parent).each do |plugin|
        $:.unshift File.join(File.dirname(__FILE__), '..', plugin, 'lib')
        require plugin
        require File.join(File.dirname(__FILE__), '..', plugin, 'init')
      end

      ActiveRecord::Base.observers = :activity_observer
    end
  end
end
