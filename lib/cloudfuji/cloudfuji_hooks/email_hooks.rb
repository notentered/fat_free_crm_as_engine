class EmailHooks < Cloudfuji::EventObserver
  # NOTE: It'd be nice to have a before_filter.

  # "email_delivered"
  # :message_headers  => "[[\"Received\", \"by luna.mailgun.net with SMTP mgrt 7313261; Tue, 20 Mar 2012 19:00:58 +0000\"], [\"Received\", \"from localhost.localdomain (ec2-23-20-14-40.compute-1.amazonaws.com [23.20.14.40]) by mxa.mailgun.org with ESMTP id 4f68d3e9.4ddcdf0-luna; Tue, 20 Mar 2012 19:00:57 -0000 (UTC)\"], [\"Date\", \"Tue, 20 Mar 2012 19:00:57 +0000\"], [\"From\", \"Sean Grove <sean@cloudfuji.com>\"], [\"Reply-To\", \"Cloudfuji Team <support@cloudfuji.com>\"], [\"Message-Id\", \"<4f68d3e9ad834_3c29377ea432615@ip-10-190-150-17.mail>\"], [\"X-Mailgun-Campaign-Id\", \"cloudfuji_buddies\"], [\"Repy-To\", \"support@cloudfuji.com\"], [\"To\", \"s+cfdemo@cloudfuji.com\"], [\"Subject\", \"Cloudfuji Beta: Thank you for your early support. Here's a gift for you.\"], [\"List-Unsubscribe\", \"<mailto:u+na6wcn3gmqzdszbsmrrdam3ghfstkzrxgbstgn3fgvtdgzjumvrgmyzgmm6tqnlkgetheplteuzeey3gmrsw23zfgqyge5ltnbus4zdpez2d2jjsietgipjrmi4a@email.cloudfuji.com>\"], [\"X-Mailgun-Sid\", \"WyI2NWQ4MSIsICJzK2NmZGVtb0BidXNoaS5kbyIsICIxYjgiXQ==\"], [\"Sender\", \"sean=cloudfuji.com@cloudfuji.com\"]]"
  # :message_id       =>"<4f68d3e9ad834_3c29377ea432615@ip-10-190-150-17.mail>"
  # :recipient        => "s+cfdemo@cloudfuji.com"
  # :domain           => "cloudfuji.com"
  # :custom_variables => nil
  # :human            =>"Mail to s+cfdemo@cloudfuji.com successfully delievered."}}
  def email_delivered
    message  = ""
    message += "Email delivered to #{recipient}"
    message += " in email campaign '#{campaign.titleize}'" if campaign
      
    note_email_activity( message.strip )
  end

  # "email_opened"
  # :recipient=>"s+cfdemo@cloudfuji.com"
  # :domain=>"cloudfuji.com"
  # :campaign_id=>"cloudfuji_buddies"
  # :campaign_name=>"Cloudfuji Buddies"
  # :tag=>nil
  # :mailing_list=>nil
  # :custom_variables=>nil
  def email_opened
    message  = ""
    message += "Email opened by #{recipient}"
    message += " in email campaign '#{campaign.titleize}" if campaign

    note_email_activity( message.strip )
  end

  # :event=>"clicked"
  # :recipient=>"s+cfdemo@cloudfuji.com"
  # :domain=>"cloudfuji.com"
  # :campaign_id=>"cloudfuji_buddies"
  # :campaign_name=>"Cloudfuji Buddies"
  # :tag=>nil
  # :mailing_list=>nil
  # :custom_variables=>nil
  # :url=>"https://cloudfuji.com/cas/invite/?invitation_token=8hswc7kqhPys6FsUJ1Nm&service=https://cloudfuji.com/users/service&redirect=https://cloudfuji.com/apps/new?app=fat_free_crm&src=icon"
  # :human=>"s+cfdemo@cloudfuji.com clicked on link in Cloudfuji Buddies to https://cloudfuji.com/cas/invite/?invitation_token=8hswc7kqhPys6FsUJ1Nm&service=https://cloudfuji.com/users/service&redirect=https://cloudfuji.com/apps/new?app=fat_free_crm&src=icon"}
  def email_clicked
    message = "#{recipient} clicked #{data['url']}"
    message += "in email campaign '#{campaign.titleize}" if campaign

    note_email_activity(message)
  end


  def email_subscribed
    note_email_activity("#{recipient} subscribed to a mailing list")
  end

  private

  def note_email_activity(message)
    subject = find_or_create_activity_subject!
    puts "Found subject: #{subject.inspect}"

    # Placeholder for now
    user = User.first
    puts "Assigning to user: #{user.inspect}"

    note         = subject.comments.new
    note.comment = message
    note.user    = user
    note.save
  end

  def data
    params['data']
  end

  def find_or_create_activity_subject!
    lookups = [Account, Lead, Contact]
    lookups.each do |model|
      puts "#{model}.find_by_email( #{recipient} )"
      result = model.find_by_email(recipient)
      return result if result
    end

    puts "No pre-existing records found, creating a lead"
    lead   = Lead.find_by_email(recipient)
    lead ||= Lead.new

    lead.email = recipient
    lead.first_name = recipient.split("@").first if lead.first_name.blank?
    lead.last_name  = recipient.split("@").last  if lead.last_name.blank?
    lead.user       = User.first if lead.user_id.nil?

    puts "About to save:"
    puts lead.inspect

    lead.save!

    puts lead.inspect

    lead
  end

  # Temp workarounds until umi delivers events properly
  # Good example of the necessity of deep-schema enforcement for events
  def headers
    begin
      JSON(data['message_headers'])
    rescue => e
      return []
    end
  end

  def recipient
    data['recipient']
  end

  def custom_variables
    JSON(data['custom_variables'])
  end

  def campaign
    campaign   = data['campaign_id'] || data['campaign_name']
    campaign ||= headers.select{|key, value| key == "X-Mailgun-Campaign-Id"}.try(:first).try(:last) unless headers.empty?
    campaign
  end
end
