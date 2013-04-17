class IsParanoidToPaperTrail < ActiveRecord::Migration
  def up
    $BEFORE_NAMESPACE = true
    [FatFreeCrm::Account, FatFreeCrm::Campaign, FatFreeCrm::Contact, FatFreeCrm::Lead, FatFreeCrm::Opportunity, FatFreeCrm::Task].each do |klass|
      klass.where('deleted_at IS NOT NULL').each do |object|
        object.destroy
      end
    end
    $BEFORE_NAMESPACE = false
  end

  def down
  end
end
