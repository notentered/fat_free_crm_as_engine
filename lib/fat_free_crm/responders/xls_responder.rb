module XlsResponder
  def to_xls
    send_data resource.to_xls, :type => :xls
  end
end
