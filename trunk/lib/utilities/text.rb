module Utilities::Text
  # Create the next version of a name.  If it ends with a numeric, increment it.  If not, answer the
  # default which is sent in (or nil if one is not).
  def increment_name(name, default = nil)
    tail = name.split.last
    tail.to_i != 0 ? name.chomp(tail) + (tail.to_i + 1).to_s : default
  end
end