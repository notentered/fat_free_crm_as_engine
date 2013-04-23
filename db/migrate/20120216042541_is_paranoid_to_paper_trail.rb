class IsParanoidToPaperTrail < ActiveRecord::Migration
  def up
    FatFreeCrm::Account.table_name = 'accounts'
    FatFreeCrm::Campaign.table_name = 'campaigns'
    FatFreeCrm::Contact.table_name = 'contacts'
    FatFreeCrm::Lead.table_name = 'leads'
    FatFreeCrm::Opportunity.table_name = 'opportunities'
    FatFreeCrm::Task.table_name = 'tasks'

    [FatFreeCrm::Account, FatFreeCrm::Campaign, FatFreeCrm::Contact, FatFreeCrm::Lead, FatFreeCrm::Opportunity, FatFreeCrm::Task].each do |klass|
      klass.where('deleted_at IS NOT NULL').each do |object|
        object.destroy
      end
    end
  end

  def down
  end
end
