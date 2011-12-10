Dir[ File.dirname(__FILE__) + "/responders/*.rb" ].each { |file| require(file) }

class FFCrmResponder < ActionController::Responder
  include AtomResponder
  include CsvResponder
  include RssResponder
  include XlsResponder
end
