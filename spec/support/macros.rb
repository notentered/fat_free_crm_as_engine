#----------------------------------------------------------------------------
def set_current_tab(tab)
  controller.session[:current_tab] = tab
end

#----------------------------------------------------------------------------
def stub_task(view)
  if view == "completed"
    assigns[:task] = FactoryGirl.create(:task, :completed_at => Time.now - 1.minute)
  elsif view == "assigned"
    assigns[:task] = FactoryGirl.create(:task, :assignee => FactoryGirl.create(:user))
  else
    assigns[:task] = FactoryGirl.create(:task)
  end
end

#----------------------------------------------------------------------------
def stub_task_total(view = "pending")
  settings = (view == "completed" ? FatFreeCrm::Setting.task_completed : FatFreeCrm::Setting.task_bucket)
  settings.inject({ :all => 0 }) { |hash, key| hash[key] = 1; hash }
end

# Get current server timezone and set it (see rake time:zones:local for details).
#----------------------------------------------------------------------------
def set_timezone
  offset = [ Time.now.beginning_of_year.utc_offset, Time.now.beginning_of_year.change(:month => 7).utc_offset ].min
  offset *= 3600 if offset.abs < 13
  Time.zone = ActiveSupport::TimeZone.all.select { |zone| zone.utc_offset == offset }.first
end

# Adjusts current timezone by given offset (in seconds).
#----------------------------------------------------------------------------
def adjust_timezone(offset)
  if offset
    ActiveSupport::TimeZone[offset]
    adjusted_time = Time.now + offset.seconds
    Time.stub(:now).and_return(adjusted_time)
  end
end

