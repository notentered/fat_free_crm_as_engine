require "fat_free_crm"

require 'sass'

#---------------------------------------------------------------------
Sass::Plugin.add_template_location File.join(Rails.root, "app/stylesheets")
Sass::Plugin.options[:css_location] = File.join(Rails.root, "public/stylesheets")

