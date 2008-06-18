class SurveyMapping < ActiveRecord::Base
  belongs_to :survey
  belongs_to :story
  
  validates_presence_of :survey_id, :priority
  validates_numericality_of :priority

  attr_accessible :survey_id, :story_id, :priority

  # Override to_xml to exclude private attributes.
  def to_xml(options = {})
    if !options[:except]
      options[:except] = []
    end
    options[:except] << :id
    options[:except] << :survey_id
    super(options)
  end
end