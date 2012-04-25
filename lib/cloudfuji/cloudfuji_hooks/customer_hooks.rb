class CustomerHooks < Cloudfuji::EventObserver
  # "customer_created"
  # :account_balance => 0
  # :object          => "customer"
  # :email           => "s+cfdemo@cloudfuji.com"
  # :created         => 1332269951
  # :id              => "cus_cpkg4h0KfLD3lp"
  # :livemode        => true
  # :human           => "Customer CREATED (cus_cpkg4h0KfLD3lp), s+cfdemo@cloudfuji.com"}
  def customer_created
    note_customer_activity("#{data['email']} created as a customer with external id #{data['id']}") if data['livemode']
  end

  def customer_signed_up
    note_customer_activity("#{data['first_name']} #{data['last_name']} (#{data['email']}) signed up as a customer")
  end

  private

  def note_customer_activity(message)
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
      puts "#{model}.find_by_email( #{data['email']} )"
      result = model.find_by_email(data['email'])
      return result if result
    end

    lead = Lead.find_by_email(data['email'])
    lead ||= Lead.new

    lead.email        = data['email']
    lead.first_name ||= data['first_name'] || recipient.split("@").first if lead.first_name.blank?
    lead.last_name  ||= data['last_name']  || recipient.split("@").last  if lead.last_name.blank?

    lead.save

    lead
  end
end
