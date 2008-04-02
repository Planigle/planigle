module StoriesHelper  
  NoOwner = 'No Owner'
  NoIteration = 'Backlog'
  
  # Map user displayable terms to the internal status codes (in this case, they're the same).
  def status_mapping
    Story.valid_status_values.collect { |val| [val, val] }
  end
  
  # Answer a string to represent the story's iteration.
  def iteration(story)
    (iteration=story.iteration) ? iteration.name : NoIteration
  end
  
  # Answer a hash mapping iteration names to their ids.
  def iteration_mapping
    mapping = Iteration.find(:all, :order=>'start').collect {|iteration| [iteration.name, iteration.id]}
    mapping << [NoIteration, nil]
    mapping
  end
  
  # Answer a string to represent the story's owner.
  def individual(story)
    (individual=story.individual) ? individual.display_name : NoOwner
  end
  
  # Answer a hash mapping individuals to their ids.
  def individual_mapping
    mapping = Individual.find(:all, :order=>'first_name, last_name').collect {|individual| [individual.display_name, individual.id]}
    mapping << [NoOwner, nil]
    mapping
  end
end
