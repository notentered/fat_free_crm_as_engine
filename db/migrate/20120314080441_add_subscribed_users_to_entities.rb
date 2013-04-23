class AddSubscribedUsersToEntities < ActiveRecord::Migration
  def change
    FatFreeCrm::Account.table_name = 'accounts'
    FatFreeCrm::Campaign.table_name = 'campaigns'
    FatFreeCrm::Contact.table_name = 'contacts'
    FatFreeCrm::Lead.table_name = 'leads'
    FatFreeCrm::Opportunity.table_name = 'opportunities'
    FatFreeCrm::Task.table_name = 'tasks'
    FatFreeCrm::Comment.table_name = 'comments'

    [FatFreeCrm::Account, FatFreeCrm::Campaign, FatFreeCrm::Contact, FatFreeCrm::Lead, FatFreeCrm::Opportunity, FatFreeCrm::Task].each do |model|
      add_column model.table_name.to_sym, :subscribed_users, :text
      # Reset the column information of each model
      model.reset_column_information
    end

    entity_subscribers = Hash.new(Set.new)

    # Add comment's user to the entity's Set
    FatFreeCrm::Comment.all.each do |comment|
      entity_subscribers[[comment.commentable_type, comment.commentable_id]] += [comment.user_id]
    end

    # Run as one atomic action.
    ActiveRecord::Base.transaction do
      entity_subscribers.each do |entity, user_ids|
        connection.execute "UPDATE #{entity[0].tableize} SET subscribed_users = '#{user_ids.to_a.to_yaml}' WHERE id = #{entity[1]}"
      end
    end
  end
end
