class IterationTotal < Total
  belongs_to :iteration

  # This should be overridden in subclasses.
  def self.id_field
    :iteration_id
  end
  
  # Answer the items to measure the effort (tasks in this case).
  def self.find_items(object, team)
    object.stories.find(:all, :conditions => {:team_id => team ? team.id : nil}).inject(Array.new) {|collect, story| collect.concat(story.tasks)}
  end
end