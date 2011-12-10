module CsvResponder
  def to_csv
    send_data resource.to_csv, :type => :csv
  end
end
