# To interact with projects on Planigle, use code like:
#   project = Project.create(:name => 'New Project')
#
#   projects = Project.find(:all)
#
#   project.survey_mode = 2
#   project.save
#
#   project.destroy
#
# See remote.rb in this directory for more information on interacting with Planigle via REST.
#
# See attr_accessible in /app/models/project.rb for a list of allowed fields.  That file also contains information on survey
# modes.

class Project < Resource

  # Answer my teams
  def teams
    Team.find(:all, :params => {:project_id => id})
  end
  
  # Add a team to me
  def add_team(team)
    team.project_id = id
  end
end