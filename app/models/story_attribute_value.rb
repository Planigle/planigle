class StoryAttributeValue < ActiveRecord::Base
  belongs_to :story_attribute
  belongs_to :release
  # attr_accessible :value, :story_attribute_id, :release_id
  audited :except => [:release_id, :story_attribute_id]

  validates_length_of       :value, :maximum => 100, :allow_nil => true # Allow nil to workaround bug
  
  before_destroy :before_destroy
  
  def name
    value
  end
  
  # Remove any story value instances (no association, so must do manually).
  def before_destroy
    StoryValue.where(story_attribute_id: story_attribute_id, value: id.to_s).each {|value| value.destroy}
  end
end