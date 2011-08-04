require "rails"

module FatFreeCrm
  class Engine < Rails::Engine
    initializer "static assets" do |app|
      app.middleware.insert_before(::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public")
    end

    # Load our packaged plugins
    config.before_initialize do
      Rails.application.config.paths.vendor.plugins.push File.expand_path('../../../vendor/plugins', __FILE__)
      Dir.glob(File.expand_path('../../../vendor/plugins', __FILE__) + "/*").each do |plugin_path|
        # Add each plugin's lib folder to the path, then run init.rb
        $: << File.join(plugin_path, 'lib')
        require File.join(plugin_path, 'init.rb')
      end
    end
  end
end

