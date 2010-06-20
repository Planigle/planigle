# To interact with teams on Planigle, use code like (Note: teams must have a story_id):
#   team = Team.create(:name => 'team a', :project_id => Project.find(:first, :name => "New Project").id)
#
#   teams = project.teams
#
#   team.name = 'team b'
#   team.save
#
#   team.destroy
#
# See remote.rb in this directory for more information on interacting with Planigle via REST.
#
# See attr_accessible in /app/models/team.rb for a list of allowed fields.  See story.rb in that same direcotry for valid status codes.

class Team < Resource
  self.prefix = Resource.site.to_s + "projects/:project_id/"
end