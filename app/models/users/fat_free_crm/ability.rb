# See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

class FatFreeCrm::Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?
      entities = [FatFreeCrm::Account, FatFreeCrm::Campaign, FatFreeCrm::Contact, FatFreeCrm::Lead, FatFreeCrm::Opportunity]

      can :create, :all
      can :read, [FatFreeCrm::User] # for search autocomplete
      can :manage, entities, :access => 'Public'
      can :manage, entities + [FatFreeCrm::Task], :user_id => user.id
      can :manage, entities + [FatFreeCrm::Task], :assigned_to => user.id
      
      #
      # Due to an obscure bug (see https://github.com/ryanb/cancan/issues/213)
      # we must switch on user.admin? here to avoid the nil constraints which
      # activate the issue referred to above.
      #
      if user.admin?
        can :manage, :all
      else
        # Group or User permissions
        t = FatFreeCrm::Permission.arel_table
        scope = t[:user_id].eq(user.id)

        if (group_ids = user.group_ids).any?
          scope = scope.or(t[:group_id].eq_any(group_ids))
        end

        entities.each do |klass|
          if (asset_ids = FatFreeCrm::Permission.where(scope.and(t[:asset_type].eq(klass.name))).value_of(:asset_id)).any?
            can :manage, klass, :id => asset_ids
          end
        end
      end # if user.admin?
      
    end
  end
end
