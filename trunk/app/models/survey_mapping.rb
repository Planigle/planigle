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
    if !options[:methods]
      options[:methods] = [:name, :description, :normalized_priority]
    end
    super(options)
  end
  
  def name
    story.name
  end
  
  def description
    story.description ? story.description : ''
  end
  
  def normalized_priority
    if story.priority && story.status_code < Story::Done
      ((((survey.survey_mappings.collect {|mapping| mapping.story}).select{|story| story.status_code<Story::Done}).collect{|story| story.priority}).sort).index(story.priority) + 1
    else
      nil
    end
  end
end