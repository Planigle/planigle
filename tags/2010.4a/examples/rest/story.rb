# To interact with stories on Planigle, use code like:
#   story = Story.create(:name => 'As a user', :individual_id => individual.id, :status_code => 0)
#
#   stories = Story.find(:all)
#
#   story.name = 'Test'
#   story.save
#
#   story.destroy
#
# See remote.rb in this directory for more information on interacting with Planigle via REST.
#
# See attr_accessible in /app/models/story.rb for a list of allowed fields.  That file also contains valid status codes.

class Story < Resource

  # Answer my tasks
  def tasks
    Task.find(:all, :params => {:story_id => id})
  end
  
  # Add a task to me
  def add_task(task)
    task.story_id = id
  end
end