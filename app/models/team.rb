class Team < ActiveRecord::Base
  belongs_to :project
  has_many :individuals, :dependent => :nullify
  has_many :stories, :dependent => :nullify

  validates_presence_of     :name
  validates_length_of       :name,                   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true

  # Prevent a user from submitting a crafted form that bypasses activation
  # Anything that the user can change should be added here.
  attr_accessible :name, :description

  # Only admins can create projects.
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
end