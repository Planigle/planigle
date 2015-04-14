class StoryValue < ActiveRecord::Base
  belongs_to :story
  belongs_to :story_attribute
  # attr_accessible :value, :story_id, :story_attribute_id
  audited

  validates_presence_of     :value
  validates_length_of       :value, :maximum => 4096, :allow_nil => true # Allow nil to workaround bug
end