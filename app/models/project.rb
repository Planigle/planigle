require 'digest/sha1'
class Project < ActiveRecord::Base
  belongs_to :company
  has_many :teams, :dependent => :destroy
  has_many :individuals, :dependent => :nullify
  has_many :releases, :dependent => :destroy
  has_many :iterations, :dependent => :destroy
  has_many :stories, :dependent => :destroy
  has_many :story_attributes, :dependent => :destroy
  has_many :surveys, :dependent => :destroy
  attr_accessible :company_id, :name, :description, :survey_mode, :premium_limit, :premium_expiry
  acts_as_audited :except => [:survey_key]

  validates_presence_of     :name, :company_id
  validates_length_of       :name,                   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_numericality_of :survey_mode
  validates_uniqueness_of   :survey_key
  validates_numericality_of :premium_limit, :only_integer => true, :allow_nil => false, :greater_than => 0

  before_create :initialize_defaults

  # Ensure that survey mode, premium expiry and premium limit are initialized.
  def initialize(attributes={})
    if (self.class.column_names.include?('survey_mode') && !attributes.include?(:survey_mode))
      attributes[:survey_mode] = Private
    end
    if (self.class.column_names.include?('premium_expiry') && !attributes.include?(:premium_expiry))
      attributes[:premium_expiry] = Date.yesterday
    end
    if (self.class.column_names.include?('premium_limit') && !attributes.include?(:premium_limit))
      attributes[:premium_limit] = 1000
    end
    super
  end
  
  # Initialize the survey key to ensure we have a unique, non-guessable id for URLs.
  def initialize_defaults
    self.survey_key = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    add_default_attributes
  end
  
  # Answer whether I am enabled for premium services.
  def is_premium
    premium_expiry && premium_expiry > Date.today
  end
  
  # Answer whether I can add new users.
  def can_add_users
    !is_premium || individuals.count < premium_limit
  end
  
  # Override to_xml to include teams.
  def to_xml(options = {})
    if !options[:include]
      options[:include] = [:story_attributes, :teams]
    end
    super(options)
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
      stories.find(:all, :order => 'priority', :conditions => ['status_code != ? and is_public=true', Story::Done]).each do |story|
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

  # Answer the records for a particular user.
  def self.get_records(current_user)
    if current_user.role >= Individual::ProjectAdmin
      if (current_user.is_premium)
        Project.find(:all, :include => [:story_attributes, :teams], :conditions => ["projects.company_id = ?", current_user.company_id])
      else
        Project.find(:all, :include => [:story_attributes, :teams], :conditions => ["projects.id = ?", current_user.project_id])
      end
    else
      Project.find(:all, :include => [:story_attributes, :teams], :order => 'projects.name')
    end
  end

  # Only admins can create projects.
  def authorized_for_create?(current_user)
    current_user.role <= Individual::Admin || (current_user.role <= Individual::ProjectAdmin && current_user.is_premium && current_user.company_id == company_id)
  end

  # Answer whether the user is authorized to see me.
  def authorized_for_read?(current_user)
    case current_user.role
      when Individual::Admin then true
      else current_user.project_id == id || (current_user.is_premium && current_user.company_id == company_id)
    end
  end

  # Answer whether the user is authorized for update.
  def authorized_for_update?(current_user)    
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.project_id == id || (current_user.is_premium && current_user.company_id == company_id)
      else false
    end
  end

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.is_premium && current_user.company_id == company_id
      else false
    end
  end
  
  # Add the default attributes for a story.
  def add_default_attributes
    story_attributes << StoryAttribute.new(:name => 'Name', :is_custom => false, :value_type => StoryAttribute::String, :width => 300, :ordering => 10, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Iteration', :is_custom => false, :value_type => StoryAttribute::List, :width => 135, :ordering => 20, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Team', :is_custom => false, :value_type => StoryAttribute::List, :width => 135, :ordering => 30, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Owner', :is_custom => false, :value_type => StoryAttribute::List, :width => 135, :ordering => 40, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Size', :is_custom => false, :value_type => StoryAttribute::Number, :width => 65, :ordering => 50, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Time', :is_custom => false, :value_type => StoryAttribute::Number, :width => 65, :ordering => 60, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Status', :is_custom => false, :value_type => StoryAttribute::List, :width => 100, :ordering => 70, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Public', :is_custom => false, :value_type => StoryAttribute::List, :width => 60, :ordering => 80, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Rank', :is_custom => false, :value_type => StoryAttribute::Number, :width => 65, :ordering => 90, :show => true)
    story_attributes << StoryAttribute.new(:name => 'User Rank', :is_custom => false, :value_type => StoryAttribute::Number, :width => 90, :ordering => 100, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Description', :is_custom => false, :value_type => StoryAttribute::Text, :width => 300, :ordering => 110, :show => false)
    story_attributes << StoryAttribute.new(:name => 'Acceptance Criteria', :is_custom => false, :value_type => StoryAttribute::Text, :width => 300, :ordering => 120, :show => false)
    story_attributes << StoryAttribute.new(:name => 'Release', :is_custom => false, :value_type => StoryAttribute::List, :width => 135, :ordering => 130, :show => false)
  end

protected
  
  # Add custom validation of the status field and relationships to give a more specific message.
  def validate()
    if survey_mode < 0 || survey_mode >= ModeMapping.length
      errors.add(:survey_mode, ' is invalid')
    end
  end
end