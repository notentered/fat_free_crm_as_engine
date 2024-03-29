class FatFreeCrm::EntityObserver < ActiveRecord::Observer
  observe FatFreeCrm::Account, FatFreeCrm::Contact, FatFreeCrm::Lead, FatFreeCrm::Opportunity

  def after_create(item)
    send_notification_to_assignee(item) if current_user != item.assignee
  end

  def after_update(item)
    if item.assigned_to_changed? && item.assignee != current_user
      send_notification_to_assignee(item)
    end
  end

  private

  def send_notification_to_assignee(item)
    FatFreeCrm::UserMailer.assigned_entity_notification(item, current_user).deliver if item.assignee.present? && current_user.present?
  end

  def current_user
    # this deals with whodunnit inconsistencies, where in some cases it's set to a user's id and others the user object itself
    user_id_or_user = PaperTrail.whodunnit
    if user_id_or_user.is_a?(FatFreeCrm::User)
      user_id_or_user
    elsif user_id_or_user.is_a?(String)
      FatFreeCrm::User.find_by_id(user_id_or_user.to_i)
    end
  end
end
