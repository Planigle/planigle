class StoryAttribute < ActiveRecord::Base
  belongs_to :project
  has_many :individual_story_attributes, :dependent => :destroy
  has_many :story_attribute_values, :dependent => :destroy
  has_many :story_values, :dependent => :destroy
  audited :except => [:project_id]

  validates_presence_of     :name, :value_type
  validates_length_of       :name, :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_numericality_of :value_type
  validates_numericality_of :ordering, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :width, :allow_nil => true, :greater_than_or_equal_to => 0
  validate :validate

  # Assign an order on creation
  before_create :initialize_defaults

  String = 0
  Text = 1
  Number = 2
  List = 3
  ReleaseList = 4
  Date = 5

  # Override attributes to allow setting of values.
  def assign_attributes(new_attributes)
    if new_attributes.include? :values
      update_values(new_attributes[:values].split(','))
      new_attributes.delete(:values)
    end
    super(new_attributes)
  end
  
  # Update the values based on the new values.  Values are of the format of either the raw value or @id@value or release_id@value.
  def update_values(new_values)
    story_attribute_values.each {|oldval| if !new_values.include?(oldval.value) && !new_values.include?(oldval.release_id.to_s + '@' + oldval.value) && !(new_values.detect{|newval| newval.match(/@#{oldval.id}@.*/)}); oldval.destroy; end}
    new_values.each do |newval|
      match = /@(.*)@(.*)/.match(newval)
      if match
        value = story_attribute_values.where(id: match[1]).first
        if value
          value.value = match[2]
          value.save( :validate=> false )
        end
      else
        match = /(.*)@(.*)/.match(newval)
        if match
          if !story_attribute_values.where(release_id: match[1], value: (match[2] == "" ? nil : match[2])).first
            story_attribute_values << StoryAttributeValue.new(:release_id => match[1], :value => (match[2] == "" ? nil : match[2]))
          end  
        elsif !story_attribute_values.where(value: newval).first
          story_attribute_values << StoryAttributeValue.new(:value => newval)
        end
      end
    end
    if !new_record?
      story_attribute_values(true) # Force reload so that updated values will be used
    end
  end

  # Set the initial order to the number of story attributes (+1 for me).  Set public to false if not set.
  def initialize_defaults
    if !self.ordering
      highest = StoryAttribute.where(project_id: project_id).order('ordering desc').first
      self.ordering = highest ? highest.ordering + 10 : 10
    end
    if self.width == nil
      self.width = value_type == StoryAttribute::Number ? 65 : 135
    end
  end

  # Answer the records for a particular user.
  def self.get_records(current_user)
    if current_user.role >= Individual::ProjectAdmin or current_user.project_id
      values = StoryAttribute.includes(:story_attribute_values, :individual_story_attributes).where(project_id: current_user.project_id)
    else
      values = StoryAttribute.includes(:story_attribute_values, :individual_story_attributes)
    end
    
    # Replace my values with those of the individual.
    values.each do |value|
      value.show_for(current_user)
    end
    values.sort{ | a, b | a.ordering <=> b.ordering }
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
      else current_user.project_id == project_id
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
  def validate
    if value_type && (value_type < 0 || value_type > StoryAttribute::Date)
      errors.add(:value_type, 'is invalid')
    end
  end  
  
  # Override as_json to include story attribute values.
  def as_json(options = {})
    if !options[:include]
      options[:include] = [:story_attribute_values]
    end
    super(options)
  end

  # Update me to reflect the values for the current user.
  def show_for(current_user)
    individual_values = individual_values_for(current_user)
    self.attributes = {:width => individual_values.width, :ordering => individual_values.ordering, :show => individual_values.show}
    readonly! # Make sure no one changes this
  end

  # Update user specific values instead of me.
  def update_for(current_user, values)
    individual_values = individual_values_for(current_user)
    if values.has_key? :width
      individual_values.width = values[:width]
      values.delete(:width)
    end
    if values.has_key? :ordering
      individual_values.ordering = values[:ordering]
      values.delete(:ordering)
    end
    if values.has_key? :show
      individual_values.show = values[:show]
      values.delete(:show)
    end
    individual_values.save
    self.attributes = values
  end
  
  def individual_values_for(current_user)
    individual_values = individual_story_attributes.where(individual_id: current_user.id).first
    if !individual_values
      individual_values = IndividualStoryAttribute.create(:story_attribute_id => id, :individual_id => current_user.id, :width => width, :ordering => ordering, :show => show)
    end
    individual_values
  end
end