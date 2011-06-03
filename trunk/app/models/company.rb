class Company < ActiveRecord::Base
  acts_as_paranoid
  has_many :projects, :dependent => :destroy, :conditions => "projects.deleted_at IS NULL"
  has_many :all_projects, :class_name => "Project"
  has_many :individuals, :dependent => :nullify, :conditions => "individuals.deleted_at IS NULL" # Delete non-admins
  attr_accessible :name
  acts_as_audited

  validates_presence_of     :name
  validates_length_of       :name,                   :maximum => 40, :allow_nil => true # Allow nil to workaround bug

  # Delete all non-admins
  def destroy
    Individual.delete_all(["company_id = ? and role != 0", id])
    super
  end

  # Answer whether records have changed.
  def self.have_records_changed(current_user, time)
    if current_user.role >= Individual::ProjectAdmin
      Company.count_with_deleted(:include => [{:all_projects => :all_teams}], :conditions => ["companies.id = ? and (companies.updated_at >= ? or companies.deleted_at >= ? or projects.updated_at >= ? or projects.deleted_at >= ? or teams.updated_at >= ? or teams.deleted_at >= ?)", current_user.company_id, time, time, time, time, time, time]) > 0
    else
      Company.count_with_deleted(:include => [{:all_projects => :all_teams}], :conditions => ["companies.updated_at >= ? or companies.deleted_at >= ? or projects.updated_at >= ? or projects.deleted_at >= ? or teams.updated_at >= ? or teams.deleted_at >= ?", time, time, time, time, time, time]) > 0
    end
  end

  # Answer the records for a particular user.
  def self.get_records(current_user)
    if current_user.role >= Individual::ProjectAdmin
      all = Company.find(:all, :include => [{:projects => [:teams, {:story_attributes => :story_attribute_values}]}], :conditions => ["companies.id = ?", current_user.company_id])
    else
      all = Company.find(:all, :include => [{:projects => [:teams, {:story_attributes => :story_attribute_values}]}], :order => 'companies.name')
    end
    
    # Ensure we load the settings for the current user
    all.each do |company|
      company.projects.each do |project|
        if project == current_user.project
          project.story_attributes.each{|story_attribute| story_attribute.show_for(current_user)}
          project.hide_attributes = false
        else
          project.hide_attributes = true
        end
      end
    end
    
    all
  end
  
  # Override to_xml to include projects.
  def to_xml(options = {})
    if !options[:procs]
      proc = Proc.new {|opt| opt[:builder]<< filtered_projects.to_xml(:skip_instruct => true)}
      options[:procs] = [proc]
    end
    super(options)
  end
  
  # If premium, answer all projects; if not, answer just my project
  def filtered_projects
    user = Thread.current[:user]
    if !user || user.role == Individual::Admin || user.is_premium
      projects
    else
      projects.select{|project| project == user.project}
    end
  end

  # Only admins can create projects.
  def authorized_for_create?(current_user)
    if current_user.role <= Individual::Admin
      true
    else
      false
    end
  end

  # Answer whether the user is authorized to see me.
  def authorized_for_read?(current_user)
    case current_user.role
      when Individual::Admin then true
      else current_user.company_id == id
    end
  end

  # Answer whether the user is authorized for update.
  def authorized_for_update?(current_user)    
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.company_id == id
      else false
    end
  end

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    current_user.role <= Individual::Admin
  end
  
  def updated_at_string
    updated_at ? updated_at.to_s : updated_at
  end
end