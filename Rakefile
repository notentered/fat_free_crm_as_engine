# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'psych'
require 'rake'


begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "fat_free_crm"
    gem.version = "0.11.0"
    gem.author = "Michael Dvorkin"
    gem.email = "mike@fatfreecrm.com"
    gem.homepage = "http://www.fatfreecrm.com"
    gem.summary = "Fat Free CRM Engine for Rails 3"
    gem.description = "Fat Free CRM Engine for Rails 3."
    gem.files = Dir["{lib}/**/*",
                     "{app}/**/*",
                     "{config}/**/*",
                     "{db}/**/*",
                     "{public}/**/*",
                     "{vendor}/plugins/**/*"]
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end

