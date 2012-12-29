#
# Following Forem's lead, we extend the FatFreeCRM.user_class
#   class to include all the bits we need. For further reading, see
#   http://ryanbigg.com/2012/03/engines-and-authentication/
#
# must be an active_record object
# id
# username
# email
# first_name
# last_name
# suspended_at
# login_count
# single_access_token
#

class DeviseUser < ActiveRecord::Base

  

end
