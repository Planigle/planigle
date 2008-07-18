class System < ActiveRecord::Base
  attr_accessible :license_agreement

  # No one is authorized to create.  It is a singleton.
  def authorized_for_create?(current_user)
    false
  end

  # Everyone can read.
  def authorized_for_read?(current_user)
    true
  end

  # Only admins can write.
  def authorized_for_update?(current_user)    
    current_user.role == Individual::Admin
  end

  # No one is authorized to delete.  It is a singleton.
  def authorized_for_destroy?(current_user)
    false
  end
end