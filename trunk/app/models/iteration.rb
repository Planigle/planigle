class Iteration < ActiveRecord::Base
  include Utilities::Text
  belongs_to :project
  has_many :stories, :dependent => :nullify
  
  validates_presence_of     :project_id, :name, :start
  validates_length_of       :name,   :within => 1..40  
  validates_numericality_of :length

  # Prevent a user from submitting a crafted form that bypasses activation
  # Anything that the user can change should be added here.
  attr_accessible :name, :start, :length, :project_id

  # If project is set, set the default values based on that project.
  def project=(project)
    self.project_id=(project ? project.id : nil)
  end
  
  # If project is set, set the default values based on that project.
  def project_id=(project_id)
    if project_id
      last_iteration = self.class.find(:first, :conditions => ["project_id = ?", project_id], :order=>'start desc')
      update_based_on(last_iteration)
      stories.each {|story| story.project_id = project_id; story.save(false)}
    end
    write_attribute(:project_id, project_id)
  end
  
protected
  
  # Ensure length is a positive number.
  def validate
    errors.add(:length, 'must be greater than 0') if length && length <= 0
  end
  
  # Update based on a template iteration.
  def update_based_on(last_iteration)
    if last_iteration
      if !self.name; self.name = increment_name(last_iteration.name, nil); end
      if !self.start; self.start = last_iteration.start + last_iteration.length * 7; end
      if !self.length; self.length = last_iteration.length; end
    else
      if !self.name; self.name = 'Iteration 1'; end
      if !self.start; self.start = Date.today; end
      if !self.length; self.length = 2; end
    end
  end
end
