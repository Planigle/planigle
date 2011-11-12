class Iteration < ActiveRecord::Base
  include Utilities::Text
  acts_as_paranoid
  belongs_to :project
  has_many :stories, :dependent => :nullify, :conditions => "stories.deleted_at IS NULL"
  has_many :iteration_totals, :dependent => :destroy
  has_many :iteration_story_totals, :dependent => :destroy
  has_many :iteration_velocities, :dependent => :destroy
  attr_accessible :name, :start, :finish, :project_id, :retrospective_results, :notable
  acts_as_audited
  
  validates_presence_of     :project_id, :name, :start, :finish
  validates_length_of       :name,   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :retrospective_results, :maximum => 4096, :allow_nil => true

  # If project is set, set the default values based on that project.
  def project=(project)
    self.project_id=(project ? project.id : nil)
  end
  
  # If project is set, set the default values based on that project.
  def project_id=(project_id)
    if project_id
      stories.each {|story| story.project_id = project_id; story.save(false)}
    end
    write_attribute(:project_id, project_id)
  end

  # Answer whether records have changed.
  def self.have_records_changed(current_user, time)
    Iteration.count_with_deleted(:conditions => ["project_id = ? and (updated_at >= ? or deleted_at >= ?)", current_user.project_id, time, time]) > 0
  end

  # Answer the records for a particular user.
  def self.get_records(current_user)
    Iteration.find(:all, :conditions => ["project_id = ?", current_user.project_id ], :order => 'start')
  end

  # Answer the current iteration for a particular user.
  def self.find_current(current_user, release=nil)
    if release
      current_user.project_id ? Iteration.find(:first, :conditions => ["project_id = ? and start <= CURDATE() and finish >= CURDATE() and start <= ? and finish >= ?", current_user.project_id, release.finish, release.start], :order => 'start,finish') : nil
    else
      current_user.project_id ? Iteration.find(:first, :conditions => ["project_id = ? and start <= CURDATE() and finish >= CURDATE()", current_user.project_id], :order => 'start,finish') : nil
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
  
protected
  
  # Ensure finish is greater than start.
  def validate
    errors.add(:finish, 'must be greater than start') if finish && start && finish <= start
  end
end