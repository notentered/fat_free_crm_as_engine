#
# Following Forem's lead, we extend the FatFreeCRM.user_class
#   class to include all the bits we need. For further reading, see
#   http://ryanbigg.com/2012/03/engines-and-authentication/
#

#
# Your user model must have this required schema
#
# id
# username
# email
# first_name
# last_name
# suspended_at
# login_count
# single_access_token

if FatFreeCRM.user_class
  FatFreeCRM.user_class.class_eval do
    
    attr_protected :admin, :suspended_at
    # Store current user in the class so we could access it from the activity
    # observer without extra authentication query.
    cattr_accessor :current_user

    before_create  :check_if_needs_approval
    before_destroy :check_if_current_user, :check_if_has_related_assets

    has_one     :avatar, :as => :entity, :dependent => :destroy, :foreign_key => "user_id"  # Personal avatar.
    has_many    :avatars, :foreign_key => "user_id"                                         # As owner who uploaded it, ex. Contact avatar.
    has_many    :comments, :as => :commentable, :foreign_key => "user_id"                   # As owner who crated a comment.
    has_many    :accounts, :foreign_key => "user_id"
    has_many    :campaigns, :foreign_key => "user_id"
    has_many    :leads, :foreign_key => "user_id"
    has_many    :contacts, :foreign_key => "user_id"
    has_many    :opportunities, :foreign_key => "user_id"
    has_many    :assigned_opportunities, :class_name => 'Opportunity', :foreign_key => 'assigned_to'
    has_many    :permissions, :dependent => :destroy, :foreign_key => "user_id"
    has_many    :preferences, :dependent => :destroy, :foreign_key => "user_id"
    has_and_belongs_to_many :groups, :foreign_key => "user_id"

    has_paper_trail :ignore => [:last_request_at, :perishable_token]

    scope :by_id, order('id DESC')
    scope :except, lambda { |user| where('id != ?', user.id).by_name }
    scope :by_name, order('first_name, last_name, email')

    scope :text_search, lambda { |query|
      query = query.gsub(/[^\w\s\-\.'\p{L}]/u, '').strip
      # TODO fix sql
      where('upper(username) LIKE upper(:s) OR upper(first_name) LIKE upper(:s) OR upper(last_name) LIKE upper(:s)', :s => "%#{query}%")
    }

    scope :my, lambda {
      accessible_by(FatFreeCRM.user_class.current_ability)
    }

    # TODO fix sql
    scope :have_assigned_opportunities, joins("INNER JOIN opportunities ON users.id = opportunities.assigned_to").
                                        where("opportunities.stage <> 'lost' AND opportunities.stage <> 'won'")

    validates_presence_of :email, :message => :missing_email

    #----------------------------------------------------------------------------
    def name
      self.first_name.blank? ? self.username : self.first_name
    end

    #----------------------------------------------------------------------------
    def full_name
      self.first_name.blank? && self.last_name.blank? ? self.email : "#{self.first_name} #{self.last_name}".strip
    end

    #----------------------------------------------------------------------------
    def suspended?
      self.suspended_at != nil
    end

    #----------------------------------------------------------------------------
    def awaits_approval?
      self.suspended? && self.login_count == 0 && Setting.user_signup == :needs_approval
    end

    #----------------------------------------------------------------------------
    def preference
      @preference ||= Preference.new(:user => self)
    end
    alias :pref :preference

    #----------------------------------------------------------------------------
    def deliver_password_reset_instructions!
      reset_perishable_token!
      UserMailer.password_reset_instructions(self).deliver
    end

    # Override global I18n.locale if the user has individual local preference.
    #----------------------------------------------------------------------------
    def set_individual_locale
      I18n.locale = self.preference[:locale] if self.preference[:locale]
    end

    # Generate the value of single access token if it hasn't been set already.
    #----------------------------------------------------------------------------
    def set_single_access_token
      self.single_access_token ||= update_attribute(:single_access_token, Authlogic::Random.friendly_token)
    end

    # Massage value when using Chosen select box which gives values like ["", "1,2,3"] 
    #----------------------------------------------------------------------------
    def group_ids=(value)
      value = value.join.split(',').map(&:to_i) if value.map{|v| v.to_s.include?(',')}.any?
      super(value)
    end


    private

    # Suspend newly created user if signup requires an approval.
    #----------------------------------------------------------------------------
    def check_if_needs_approval
      self.suspended_at = Time.now if Setting.user_signup == :needs_approval && !self.admin
    end

    # Prevent current user from deleting herself.
    #----------------------------------------------------------------------------
    def check_if_current_user
      FatFreeCRM.user_class.current_user.nil? || FatFreeCRM.user_class.current_user != self
    end

    # Prevent deleting a user unless she has no artifacts left.
    #----------------------------------------------------------------------------
    def check_if_has_related_assets
      artifacts = %w(Account Campaign Lead Contact Opportunity Comment).inject(0) do |sum, asset|
        klass = asset.constantize
        sum += klass.assigned_to(self).count if asset != "Comment"
        sum += klass.created_by(self).count
      end
      artifacts == 0
    end

    # Define class methods
    #----------------------------------------------------------------------------
    class << self

      def current_ability
        Ability.new(FatFreeCRM.user_class.current_user)
      end

    end
    
  end
end
