require 'digest/sha1'
class Project < ActiveRecord::Base
  has_many :individuals, :dependent => :destroy
  has_many :iterations, :dependent => :destroy
  has_many :stories, :dependent => :destroy
  has_many :surveys, :dependent => :destroy

  validates_presence_of     :name
  validates_length_of       :name,                   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_numericality_of :survey_mode
  validates_uniqueness_of   :survey_key

  before_create :initialize_defaults

  # Prevent a user from submitting a crafted form that bypasses activation
  # Anything that the user can change should be added here.
  attr_accessible :name, :description, :survey_mode

  # Ensure that survey mode is initialized.
  def initialize(attributes={})
    if (!attributes.include? :survey_mode)
      attributes[:survey_mode] = Private
    end
    super
  end
  
  # Initialize the survey key to ensure we have a unique, non-guessable id for URLs.
  def initialize_defaults
    self.survey_key = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  ModeMapping = [ 'Private', 'Private by default', 'Public by default' ]
  Private = 0
  PrivateByDefault = 1
  PublicByDefault = 2

  # Answer the valid values for mode.
  def self.valid_mode_values()
    ModeMapping
  end

  # Map user displayable terms to the internal mode codes.
  def self.mode_mapping
    i = -1
    valid_mode_values.collect { |val| i+=1;[val, i] }
  end

  # Create a survey for this project (in XML)
  def create_survey
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.stories do
      i = 1
      stories.find(:all, :order => 'priority', :conditions => 'status_code < 2 and public=true').each do |story|
        builder.story do
          builder.id story.id
          builder.name story.name
          builder.description story.description
          builder.priority i
        end
        i += 1
      end
    end
  end

  # Show survey summary info for this project (in XML)
  def show_surveys
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.surveys do
      surveys.each do |survey|
        builder.survey do
          builder.id survey.id
          builder.name survey.name
          builder.company survey.company
          builder.email survey.email
          builder.excluded survey.excluded
        end
      end
    end
  end

protected
  
  # Add custom validation of the status field and relationships to give a more specific message.
  def validate()
    if survey_mode < 0 || survey_mode >= ModeMapping.length
      errors.add(:survey_mode, ' is invalid')
    end
  end
end
