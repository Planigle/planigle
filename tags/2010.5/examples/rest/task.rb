# To interact with tasks on Planigle, use code like (Note: tasks must have a story_id):
#   task = Task.create(:story_id => story.id, :name => 'first', :individual_id => individual.id, :status_code => 0)
#
#   tasks = story.tasks
#
#   task.name = 'do this'
#   task.save
#
#   task.destroy
#
# See remote.rb in this directory for more information on interacting with Planigle via REST.
#
# See attr_accessible in /app/models/task.rb for a list of allowed fields.  See story.rb in that same direcotry for valid status codes.

class Task < Resource
  self.prefix = Resource.site.to_s + "stories/:story_id/"
end