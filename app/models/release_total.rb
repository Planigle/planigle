class ReleaseTotal < Total
  belongs_to :release
  
  # This should be overridden in subclasses.
  def self.id_field
    :release_id
  end
  
  # Answer the items to measure the effort (stories in this case).
  def self.find_items(object, team)
    object.stories.where(team_id: team ? team.id : nil)
  end
end