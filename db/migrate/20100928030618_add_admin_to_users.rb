class AddAdminToUsers < ActiveRecord::Migration
  def self.up
    $BEFORE_NAMESPACE = true
    add_column :users, :admin, :boolean, :null => false, :default => false
    superuser = FatFreeCrm::User.first
    superuser.update_attribute(:admin, true) if superuser
    $BEFORE_NAMESPACE = false
  end

  def self.down
    remove_column :users, :admin
  end
end

