require 'digest/sha1'
class Project < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :company
  has_many :teams, :dependent => :destroy, :conditions => "teams.deleted_at IS NULL"
  has_many :all_teams, :class_name => "Team"
  has_and_belongs_to_many :individuals, :conditions => "individuals.deleted_at IS NULL"
  has_many :individuals_with_selection, :class_name => "Individual", :foreign_key => "selected_project_id", :dependent => :nullify, :conditions => "individuals.deleted_at IS NULL"
  has_many :releases, :dependent => :destroy, :conditions => "releases.deleted_at IS NULL"
  has_many :iterations, :dependent => :destroy, :conditions => "iterations.deleted_at IS NULL"
  has_many :stories, :dependent => :destroy, :conditions => "stories.deleted_at IS NULL"
  has_many :story_attributes, :dependent => :destroy
  has_many :surveys, :dependent => :destroy
  attr_accessible :company_id, :name, :description, :survey_mode, :premium_limit, :premium_expiry, :track_actuals, :last_notified_of_inactivity, :last_notified_of_expiration
  acts_as_audited :except => [:survey_key]

  validates_presence_of     :name, :company_id
  validates_length_of       :name,                   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_numericality_of :survey_mode
  validates_uniqueness_of   :survey_key
  validates_numericality_of :premium_limit, :only_integer => true, :allow_nil => false, :greater_than => 0

  before_create :initialize_defaults
  before_save :update_notifications
  

  def hide_attributes
    @hide_attributes
  end

  def hide_attributes= hide_attributes
    @hide_attributes = hide_attributes
  end

  # Notify of any interesting activity.
  def self.send_notifications
    find(:all).each do |project|
      project.notify_of_inactivity
      project.notify_of_expiration
    end
  end
  
  # Update my notification fields based on changes.
  def update_notifications
    if changed_attributes['premium_expiry']
      self.last_notified_of_expiration = nil
    end
  end
  
  # Notify if none of my users have logged in for a while.
  def notify_of_inactivity
    if is_inactive
      InactivityMailer.deliver_notification(self, last_login)
      self.last_notified_of_inactivity = DateTime.now
      save(false)
    end
  end
  
  # Answer whether I am inactive.
  def is_inactive
    last_project_login = last_login
    if config_option(:notify_of_inactivity_after) && last_project_login
      if !self.last_notified_of_inactivity || last_project_login > self.last_notified_of_inactivity
        time_since_active = Time.now - last_project_login
        if time_since_active >= config_option(:notify_of_inactivity_after)*24*60*60 && (!config_option(:notify_of_inactivity_before) || time_since_active <= config_option(:notify_of_inactivity_before)*24*60*60)
          return true
        end
      end
    end
    false
  end
  
  # Answer the last time that anyone in the project logged in.
  def last_login
    last_project_login = nil
    individuals.each do |individual|
      last_login = individual.last_login
      if last_login
        last_project_login = last_project_login && last_project_login > last_login ? last_project_login : last_login
      end
    end
    last_project_login
  end
  
  # Answer the email addresses for my admins
  def admin_email_addresses
    individuals.select{|individ| individ.role == Individual::ProjectAdmin}.collect{|individ|individ.email}
  end
  
  # Notify if my premium status is about to expire
  def notify_of_expiration
    if is_about_to_expire
      ExpirationMailer.deliver_notification(self)
      self.last_notified_of_expiration = DateTime.now
      save(false)
    end
  end
  
  # Answer whether my premium subscription is about to expire.
  def is_about_to_expire
    time_until_expiration = self.premium_expiry - Date.today
    config_option(:notify_when_expiring_in) && !self.last_notified_of_expiration && time_until_expiration >= 0 && time_until_expiration <= config_option(:notify_when_expiring_in)
  end

  # Ensure that survey mode, premium expiry and premium limit are initialized.
  def initialize(attributes={})
    if (self.class.column_names.include?('survey_mode') && !attributes.include?(:survey_mode))
      attributes[:survey_mode] = Private
    end
    if (self.class.column_names.include?('premium_expiry') && !attributes.include?(:premium_expiry))
      attributes[:premium_expiry] = Date.today + 30
    end
    if (self.class.column_names.include?('premium_limit') && !attributes.include?(:premium_limit))
      attributes[:premium_limit] = 1000
    end
    if (self.class.column_names.include?('track_actuals') && !attributes.include?(:track_actuals))
      attributes[:track_actuals] = false
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
    !is_premium || individuals.count(:conditions => ['enabled = true and role < 3']) < premium_limit
  end
  
  # Override to_xml to include teams.
  def to_xml(options = {})
    if !options[:include]
      options[:include] = [:teams]
    end
    if !options[:procs]
      proc = Proc.new {|opt| filtered_attributes_as_xml(opt[:builder])}
      options[:procs] = [proc]
    end
    super(options)
  end
  
  def filtered_attributes
    hide_attributes ? [] : story_attributes
  end
  
  def filtered_attributes_as_xml(builder)
    builder.method_missing("filtered-attributes".to_sym) do
      filtered_attributes.each do |task|
        task.to_xml({:builder => builder, :skip_instruct => true, :root => :filtered_attribute})
      end
    end
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
    current_user.individual_story_attributes # load these in one shot
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
      when Individual::ProjectAdmin then current_user.is_premium && current_user.company_id == company_id && current_user.project_id != id
      else false
    end
  end
  
  # Add the default attributes for a story.
  def add_default_attributes
    story_attributes << StoryAttribute.new(:name => 'Id', :is_custom => false, :value_type => StoryAttribute::String, :width => 60, :ordering => 10, :show => false)
    story_attributes << StoryAttribute.new(:name => 'Name', :is_custom => false, :value_type => StoryAttribute::String, :width => 200, :ordering => 20, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Description', :is_custom => false, :value_type => StoryAttribute::Text, :width => 300, :ordering => 30, :show => false)
    story_attributes << StoryAttribute.new(:name => 'Acceptance Criteria', :is_custom => false, :value_type => StoryAttribute::Text, :width => 300, :ordering => 40, :show => false)
    story_attributes << StoryAttribute.new(:name => 'Release', :is_custom => false, :value_type => StoryAttribute::List, :width => 100, :ordering => 50, :show => false)
    story_attributes << StoryAttribute.new(:name => 'Iteration', :is_custom => false, :value_type => StoryAttribute::List, :width => 100, :ordering => 60, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Team', :is_custom => false, :value_type => StoryAttribute::List, :width => 75, :ordering => 70, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Owner', :is_custom => false, :value_type => StoryAttribute::List, :width => 110, :ordering => 80, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Size', :is_custom => false, :value_type => StoryAttribute::Number, :width => 50, :ordering => 90, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Estimate', :is_custom => false, :value_type => StoryAttribute::Number, :width => 60, :ordering => 100, :show => false)
    story_attributes << StoryAttribute.new(:name => 'Actual', :is_custom => false, :value_type => StoryAttribute::Number, :width => 50, :ordering => 110, :show => false)
    story_attributes << StoryAttribute.new(:name => 'To Do', :is_custom => false, :value_type => StoryAttribute::Number, :width => 50, :ordering => 120, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Status', :is_custom => false, :value_type => StoryAttribute::List, :width => 100, :ordering => 130, :show => true)
    story_attributes << StoryAttribute.new(:name => 'Public', :is_custom => false, :value_type => StoryAttribute::List, :width => 60, :ordering => 140, :show => false)
    story_attributes << StoryAttribute.new(:name => 'Rank', :is_custom => false, :value_type => StoryAttribute::Number, :width => 40, :ordering => 150, :show => true)
    story_attributes << StoryAttribute.new(:name => 'User Rank', :is_custom => false, :value_type => StoryAttribute::Number, :width => 90, :ordering => 160, :show => false)
  end
  
  def updated_at_string
    updated_at ? updated_at.to_s : updated_at
  end

protected
  
  # Add custom validation of the status field and relationships to give a more specific message.
  def validate()
    if survey_mode < 0 || survey_mode >= ModeMapping.length
      errors.add(:survey_mode, ' is invalid')
    end
  end
end