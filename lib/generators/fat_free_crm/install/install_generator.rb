require 'rails/generators/migration'

module FatFreeCrm
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      desc "Add Fat Free CRM database migrations"

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end

      def copy_migrations
        Dir.glob(File.expand_path('../templates/migrations/*', __FILE__)).sort.each do |migration|
          filename = File.basename(migration)
          migration_template "migrations/#{filename}", "db/migrate/#{filename.gsub(/\d+_/, "")}" rescue true
        end
      end

      def copy_config
        Dir.glob(File.expand_path('../templates/config/*', __FILE__)).each do |config|
          filename = File.basename(config)
          template "config/#{filename}", "config/#{filename}"
        end
      end
    end
  end
end

