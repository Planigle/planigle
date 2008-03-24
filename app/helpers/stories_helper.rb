module StoriesHelper  
  # Map user displayable terms to the internal status codes (in this case, they're the same).
  def status_mapping
    Story.valid_status_values.collect { |val| [val, val] }
  end
end
