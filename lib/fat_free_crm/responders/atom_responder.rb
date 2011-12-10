module AtomResponder
  def to_atom
    render "index.atom.builder"
  end
end
