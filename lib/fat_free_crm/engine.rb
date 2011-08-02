require "rails"

module FatFreeCrm
  class Engine < Rails::Engine
    initializer "static assets" do |app|
      app.middleware.insert_before(::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public")
    end
  end
end

