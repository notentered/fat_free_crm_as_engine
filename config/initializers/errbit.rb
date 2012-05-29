if ENV['ERRBIT_API_KEY']
  Airbrake.configure do |config|
    config.api_key = ENV['ERRBIT_API_KEY']
    config.host    = ENV['ERRBIT_HOST']
    config.port    = ENV['ERRBIT_PORT']
    config.secure  = config.port == 443
    # Send errors to Errbit in development if ENV variable is set	
    config.development_environments = [] if ENV['ERRBIT_NOTIFY_IN_DEVELOPMENT']
  end

  puts "Airbrake enabled!"
end
