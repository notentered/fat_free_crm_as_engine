# == Schema Information
#
# Table name: emails
#
#  id              :integer         not null, primary key
#  imap_message_id :string(255)     not null
#  user_id         :integer
#  mediator_id     :integer
#  mediator_type   :string(255)
#  sent_from       :string(255)     not null
#  sent_to         :string(255)     not null
#  cc              :string(255)
#  bcc             :string(255)
#  subject         :string(255)
#  body            :text
#  header          :text
#  sent_at         :datetime
#  received_at     :datetime
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  state           :string(16)      default("Expanded"), not null
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe FatFreeCrm::Email do
  before(:each) do
    @email = Email.new
  end

  it "should be valid" do
    @email.should be_valid
  end
end

