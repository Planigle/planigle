class Iteration < ActiveRecord::Base
  include Utilities::Text
  acts_as_paranoid
  belongs_to :project
  has_many :stories, -> {where(deleted_at: nil)}, dependent: :nullify
  has_many :iteration_totals, :dependent => :destroy
  has_many :iteration_story_totals, :dependent => :destroy
  has_many :iteration_velocities, :dependent => :destroy
  audited
  
  validates_presence_of     :project_id, :name, :start, :finish
  validates_length_of       :name,   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :notable,   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :retrospective_results, :maximum => 4096, :allow_nil => true
  validate :validate

  # If project is set, set the default values based on that project.
  def project=(project)
    self.project_id=(project ? project.id : nil)
  end
  
  # If project is set, set the default values based on that project.
  def project_id=(project_id)
    if project_id
      stories.each {|story| story.project_id = project_id; story.save( :validate=> false )}
    end
    write_attribute(:project_id, project_id)
  end

  # Answer the records for a particular user.
  def self.get_records(project_id, historical=false)
    where = "project_id = :project_id"
    if historical
      where += " AND start <= CURDATE()"
    end
    Iteration.where([where, {project_id: project_id}]).order('start')
  end

  # Answer the current iteration for a particular user.
  def self.find_current(project_id, release=nil)
    if release
      project_id ? Iteration.where(["project_id = :project_id and start <= CURDATE() and finish >= CURDATE() and start <= :start and finish >= :finish", {project_id: project_id, start: release.finish, finish: release.start}]).order('start,finish').first : nil
    else
      project_id ? Iteration.where(["project_id = :project_id and start <= CURDATE() and finish >= CURDATE()", {project_id: project_id}]).order('start,finish').first : nil
    end
  end
  
  # Summarize my current data.
  def summarize
    IterationTotal.summarize_for(self)
    IterationStoryTotal.summarize_for(self)
    IterationVelocity.summarize_for(self)
  end

  # Only project admins or higher can create iterations.
  def authorized_for_create?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.project_id == project_id
      else false
    end
  end

  # Answer whether the user is authorized to see me.
  def authorized_for_read?(current_user)
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

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.project_id == project_id
      else false
    end
  end
  
  def updated_at_string
    updated_at ? updated_at.to_s : updated_at
  end
  
  def lead_time(team)
    total = 0
    stories.each do |story|
      if story.team == team
        if story.lead_time != nil && story.status_code == Status.Done && story.effort != 0 && story.effort != nil
          total += story.lead_time
        end
      end
    end
    total
  end
  
  def cycle_time(team)
    total = 0
    stories.each do |story|
      if story.team == team
        if story.cycle_time != nil && story.status_code == Status.Done && story.effort != 0 && story.effort != nil
          total += story.cycle_time
        end
      end
    end
    total
  end
  
  def num_stories(team)
    stories.select {|story|story.team == team && story.status_code == Status.Done && story.effort != 0 && story.effort != nil}.length
  end

  # Override as_json to exclude private attributes.
  def as_json(options = {})
    if !options[:except]
      options[:except] = [:created_at, :updated_at, :deleted_at]
    end
    super(options)
  end  
  
protected
  
  # Ensure finish is greater than start.
  def validate
    errors.add(:finish, 'must be greater than start') if finish && start && finish <= start
  end
end