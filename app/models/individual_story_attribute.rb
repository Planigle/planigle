class IndividualStoryAttribute < ActiveRecord::Base
  belongs_to :individual
  belongs_to :story_attribute
  # attr_accessible :individual_id, :story_attribute_id, :ordering, :show, :width
  audited :except => [:individual_id, :story_attribute_id]

  validates_numericality_of :ordering, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :width, :allow_nil => true, :greater_than_or_equal_to => 0

  # Assign an order on creation
  before_create :initialize_defaults

  def name
    story_attribute.name
  end

  # Set the initial order to the number of story attributes (+10 for me).  Set public to false if not set.
  def initialize_defaults
    if !self.ordering
      highest = IndividualStoryAttribute.joins(:story_attribute).where(['story_attributes.project_id=:project_id and individual_id=:individual_id', {project_id: story_attribute.project_id, individual_id: individual_id}]).order('ordering desc').first
      self.ordering = highest ? highest.ordering + 10 : 10
    end
    if self.width == nil
      self.width = story_attribute.value_type == StoryAttribute::Number ? 65 : 135
    end
  end
end