class Comment < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :individual
  belongs_to :story
  
  validates_presence_of     :story_id, :individual_id, :message, :ordering
  validates_length_of       :message,  :maximum => 20480, :allow_nil => false
  validates_numericality_of :ordering, :allow_nil => false

  # Override as_json to include individual_name.
  def as_json(options = {})
    if !options[:except]
      options[:except] = [:deleted_at]
    end
    if !options[:methods]
      options[:methods] = [:individual_name]
    end
    super(options)
  end

  def individual_name
    individual == nil ? nil : individual.name
  end

  # Only project users or higher can create tasks.
  def authorized_for_create?(current_user)
    if current_user.role <= Individual::Admin
      true
    elsif current_user.role <= Individual::ProjectUser && story && current_user.project_id == story.project_id
      true
    else
      false
    end
  end

  # Answer whether the user is authorized to see me.
  def authorized_for_read?(current_user)
    case current_user.role
      when Individual::Admin then true
      else story && current_user.project_id == story.project_id
    end
  end

  # Answer whether the user is authorized for update.
  def authorized_for_update?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.id == individual_id
      when Individual::ProjectUser then current_user.id == individual_id
      else false
    end
  end

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then current_user.id == individual_id
      when Individual::ProjectUser then current_user.id == individual_id
      else false
    end
  end
end