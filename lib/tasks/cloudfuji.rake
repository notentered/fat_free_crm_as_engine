require 'fileutils'

namespace :cloudfuji do
  desc "Prepare an app to run on the Cloudfuji hosting platform, only called during the initial installation. Called just before booting the app for the first time."
  task :install => :environment do
    FileUtils.cp "config/settings.yml.cloudfuji", "config/settings.yml"
    Rake::Task["crm:settings:load"].invoke
  end
end

