class System < ActiveRecord::Base
  attr_accessible :license_agreement

  # Summarize my recent data for reporting.
  def self.summarize
    Release.find(:all, :conditions => ['start < ? and finish > ?', Time.now, Time.now], :include => [:stories]).each { |release| release.summarize }
    Iteration.find(:all, :conditions => ['start < ? and finish > ?', Time.now, Time.now], :include => [:stories]).each { |iteration| iteration.summarize }
  end

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