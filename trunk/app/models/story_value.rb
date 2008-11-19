class StoryValue < ActiveRecord::Base
  belongs_to :story
  belongs_to :story_attribute

  validates_presence_of     :value
  validates_length_of       :value, :maximum => 4096, :allow_nil => true # Allow nil to workaround bug

  # Prevent a user from submitting a crafted form that bypasses activation
  # Anything that the user can change should be added here.
  attr_accessible :value, :story_id, :story_attribute_id
end