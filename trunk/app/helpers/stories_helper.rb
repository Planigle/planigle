module StoriesHelper  
  # Map user displayable terms to the internal status codes (in this case, they're the same).
  def status_mapping
    Story.valid_status_values.collect { |val| [val, val] }
  end
  
  # Answer a string to represent the story's iteration.
  def iteration(story)
    (iteration=story.iteration) ? iteration.name : 'Backlog'
  end
  
  # Answer a hash mapping iteration names to their ids.
  def iteration_mapping
    mapping = Iteration.find(:all, :order=>'start').collect {|iteration| [iteration.name, iteration.id]}
    mapping << ['Backlog', nil]
    mapping
  end
end
