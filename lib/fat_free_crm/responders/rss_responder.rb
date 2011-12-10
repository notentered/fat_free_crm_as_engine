module RssResponder
  def to_rss
    render "shared/index.rss.builder"
  end
end
