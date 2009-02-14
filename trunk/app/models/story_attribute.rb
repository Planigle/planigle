class StoryAttribute < ActiveRecord::Base
  belongs_to :project
  has_many :story_attribute_values, :dependent => :destroy
  has_many :story_values, :dependent => :destroy
  attr_accessible :project_id, :name, :value_type
  acts_as_audited :except => [:project_id]

  validates_presence_of     :name, :value_type
  validates_length_of       :name,                   :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_numericality_of :value_type

  String = 0
  Text = 1
  Number = 2
  List = 3
  ReleaseList = 4

  # Override attributes to allow setting of values.
  def attributes=(new_attributes, guard_protected_attributes = true)
    if new_attributes.include? :values
      update_values(new_attributes[:values].split(','))
      new_attributes.delete(:values)
    end
    super
  end
  
  # Update the values based on the new values.  Values are of the format of either the raw value or @id@value or release_id@value.
  def update_values(new_values)
    story_attribute_values.each {|oldval| if !new_values.include?(oldval.value) && !new_values.include?(oldval.release_id.to_s + '@' + oldval.value) && !(new_values.detect{|newval| newval.match(/@#{oldval.id}@.*/)}); oldval.destroy; end}
    new_values.each do |newval|
      match = /@(.*)@(.*)/.match(newval)
      if match
        value = story_attribute_values.find(:first, :conditions => {:id => match[1]})
        if value
          value.value = match[2]
          value.save(false)
        end
      else
        match = /(.*)@(.*)/.match(newval)
        if match
          if !story_attribute_values.find(:first, :conditions=>{:release_id => match[1], :value => (match[2] == "" ? nil : match[2])})
            story_attribute_values << StoryAttributeValue.new(:release_id => match[1], :value => (match[2] == "" ? nil : match[2]))
          end  
        elsif !story_attribute_values.find(:first, :conditions=>{:value => newval})
          story_attribute_values << StoryAttributeValue.new(:value => newval)
        end
      end
    end
  end

  # Answer the records for a particular user.
  def self.get_records(current_user)
    if current_user.role >= Individual::ProjectAdmin or current_user.project_id
      StoryAttribute.find(:all, :conditions => ["project_id = ?", current_user.project_id], :order => 'name')
    else
      StoryAttribute.find(:all, :order => 'name')
    end
  end

  # Only project_admins can create story attributes.
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
  
  # Validate my values.
  def validate()
    if value_type && (value_type < 0 || value_type > ReleaseList)
      errors.add(:value_type, 'is invalid')
    end
  end  
  
  # Override to_xml to include story attribute values.
  def to_xml(options = {})
    if !options[:include]
      options[:include] = [:story_attribute_values]
    end
    super(options)
  end
end