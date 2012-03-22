class EmailHooks < Bushido::EventObserver
  # NOTE: It'd be nice to have a before_filter.

  # "email_delivered"
  # :message_headers  => "[[\"Received\", \"by luna.mailgun.net with SMTP mgrt 7313261; Tue, 20 Mar 2012 19:00:58 +0000\"], [\"Received\", \"from localhost.localdomain (ec2-23-20-14-40.compute-1.amazonaws.com [23.20.14.40]) by mxa.mailgun.org with ESMTP id 4f68d3e9.4ddcdf0-luna; Tue, 20 Mar 2012 19:00:57 -0000 (UTC)\"], [\"Date\", \"Tue, 20 Mar 2012 19:00:57 +0000\"], [\"From\", \"Sean Grove <sean@gobushido.com>\"], [\"Reply-To\", \"Bushido Team <support@bushi.do>\"], [\"Message-Id\", \"<4f68d3e9ad834_3c29377ea432615@ip-10-190-150-17.mail>\"], [\"X-Mailgun-Campaign-Id\", \"bushido_buddies\"], [\"Repy-To\", \"support@bushi.do\"], [\"To\", \"s+cfdemo@bushi.do\"], [\"Subject\", \"Bushido Beta: Thank you for your early support. Here's a gift for you.\"], [\"List-Unsubscribe\", \"<mailto:u+na6wcn3gmqzdszbsmrrdam3ghfstkzrxgbstgn3fgvtdgzjumvrgmyzgmm6tqnlkgetheplteuzeey3gmrsw23zfgqyge5ltnbus4zdpez2d2jjsietgipjrmi4a@email.bushi.do>\"], [\"X-Mailgun-Sid\", \"WyI2NWQ4MSIsICJzK2NmZGVtb0BidXNoaS5kbyIsICIxYjgiXQ==\"], [\"Sender\", \"sean=gobushido.com@gobushido.com\"]]"
  # :message_id       =>"<4f68d3e9ad834_3c29377ea432615@ip-10-190-150-17.mail>"
  # :recipient        => "s+cfdemo@bushi.do"
  # :domain           => "bushi.do"
  # :custom_variables => nil
  # :human            =>"Mail to s+cfdemo@bushi.do successfully delievered."}}
  def email_delivered
    note_email_activity("Campaign '#{campaign.titleize}' email delivered to #{recipient}")
  end

  # "email_opened"
  # :recipient=>"s+cfdemo@bushi.do"
  # :domain=>"bushi.do"
  # :campaign_id=>"bushido_buddies"
  # :campaign_name=>"Bushido Buddies"
  # :tag=>nil
  # :mailing_list=>nil
  # :custom_variables=>nil
  def email_opened
    note_email_activity("Campaign '#{campaign.titleize}' email opened by #{recipient}")
  end

  # :event=>"clicked"
  # :recipient=>"s+cfdemo@bushi.do"
  # :domain=>"bushi.do"
  # :campaign_id=>"bushido_buddies"
  # :campaign_name=>"Bushido Buddies"
  # :tag=>nil
  # :mailing_list=>nil
  # :custom_variables=>nil
  # :url=>"https://bushi.do/cas/invite/?invitation_token=8hswc7kqhPys6FsUJ1Nm&service=https://bushi.do/users/service&redirect=https://bushi.do/apps/new?app=fat_free_crm&src=icon"
  # :human=>"s+cfdemo@bushi.do clicked on link in Bushido Buddies to https://bushi.do/cas/invite/?invitation_token=8hswc7kqhPys6FsUJ1Nm&service=https://bushi.do/users/service&redirect=https://bushi.do/apps/new?app=fat_free_crm&src=icon"}
  def email_clicked
    note_email_activity("#{recipient} clicked #{data['url']} in email campaign '#{campaign.titleize}")
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
    campaign ||= headers.select{|key, value| key == "X-Mailgun-Campaign-Id"}.first.last unless headers.empty?
    campaign
  end
end
