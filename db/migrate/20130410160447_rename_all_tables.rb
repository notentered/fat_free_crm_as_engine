class RenameAllTables < ActiveRecord::Migration
  def change
    rename_table :campaigns,             :fat_free_crm_campaigns
    rename_table :users,                 :fat_free_crm_users
    rename_table :groups,                :fat_free_crm_groups
    rename_table :preferences,           :fat_free_crm_preferences
    rename_table :emails,                :fat_free_crm_emails
    rename_table :account_contacts,      :fat_free_crm_account_contacts
    rename_table :settings,              :fat_free_crm_settings
    rename_table :tasks,                 :fat_free_crm_tasks
    rename_table :contacts,              :fat_free_crm_contacts
    rename_table :activities,            :fat_free_crm_activities
    rename_table :addresses,             :fat_free_crm_addresses
    rename_table :leads,                 :fat_free_crm_leads
    rename_table :taggings,              :fat_free_crm_taggings
    rename_table :sessions,              :fat_free_crm_sessions
    rename_table :contact_opportunities, :fat_free_crm_contact_opportunities
    rename_table :opportunities,         :fat_free_crm_opportunities
    rename_table :field_groups,          :fat_free_crm_field_groups
    rename_table :comments,              :fat_free_crm_comments
    rename_table :tags,                  :fat_free_crm_tags
    rename_table :avatars,               :fat_free_crm_avatars
    rename_table :lists,                 :fat_free_crm_lists
    rename_table :permissions,           :fat_free_crm_permissions
    rename_table :accounts,              :fat_free_crm_accounts
    rename_table :account_opportunities, :fat_free_crm_account_opportunities
    rename_table :versions,              :fat_free_crm_versions
    rename_table :fields,                :fat_free_crm_fields
    rename_table :groups_users,          :fat_free_crm_groups_users
  end
end
