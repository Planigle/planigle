class Survey < ActiveRecord::Base
  require 'bigdecimal'

  belongs_to :project
  has_many :survey_mappings, :dependent => :destroy
  
  validates_presence_of     :project_id, :name, :email
  validates_length_of       :name, :maximum => 80, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :company, :maximum => 80, :allow_nil => true
  validates_length_of       :email, :within => 6..100
  validates_format_of       :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i

  after_update :notify_users
  
  # Notify admins that a new survey has been created
  def notify_users
    if project.company.is_premium
      SurveyNotificationMailer.notification(self).deliver_now
    end
  end
  
  # Override as_json to include survey mappings.
  def as_json(options = {})
    if !options[:include]
      options[:include] = [:survey_mappings]
    end
    if !options[:except]
      options[:except] = [:project_id]
    end
    super(options)
  end

  # Update the user rankings on the stories
  def apply_to_stories
    self.class.update_rankings(project)
  end
  
  # Update the user rankings on the stories for a project.
  def self.update_rankings(project)
    # For each survey, adjust priority by removing stories that have been accepted.  This ensures that
    # older surveys don't throw off the rankings.
    hash = {}
    project.surveys.includes(:survey_mappings).where(excluded: false).each do |survey|
      i = 1
      survey.survey_mappings.joins('inner join stories as s on survey_mappings.story_id = s.id').includes(:story).where(['s.status_code != :status_code', {status_code: Story.Done}]).order('survey_mappings.priority').each do |sm|
        if !hash.include? sm.story
          hash[sm.story] = []
        end
        hash[sm.story] << i
        i += 1
      end
    end

    # Now update the stories user priority to be an average.
    hash.each_key do |story| # Use BigDecimal for more precision
      story.user_priority = BigDecimal((hash[story].inject(0) {|total, priority| total + priority }).to_s) / hash[story].length
    end
    
    hash.keys
  end
  
  # Answer the stories which I am ranking
  def stories
    survey_mappings.select{|sm| sm.story_id }.collect{|sm| sm.story }
  end
  
  # Answer whether the user is authorized to see me.
  def authorized_for_read?(current_user)
    if !current_user; return false; end;
    case current_user.role
      when Individual::Admin then true
      else current_user.project_id == project_id
    end
  end

  # Answer whether the user is authorized for update.
  def authorized_for_update?(current_user)    
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.project_id == project_id
      else false
    end
  end
end