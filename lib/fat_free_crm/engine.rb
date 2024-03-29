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

module FatFreeCrm
  class Engine < ::Rails::Engine
    isolate_namespace FatFreeCrm
    config.autoload_paths += Dir[root.join("app/models/**")] +
                             Dir[root.join("app/controllers/fat_free_crm/entities")]

    # CODE SMELL
    # After the observers are namespaced, we cannot run rake db:migrate because the tables are missing (Catch-22)
    unless defined?(::Rake) and !Rails.env.test?
      config.to_prepare do
        ActiveRecord::Base.observers = 'FatFreeCrm::LeadObserver', 'FatFreeCrm::OpportunityObserver', 'FatFreeCrm::TaskObserver'
      end
    end
  end
end