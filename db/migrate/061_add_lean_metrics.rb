class AddLeanMetrics < ActiveRecord::Migration[4.2]
  def self.up
    Project.with_deleted.each do |project|
      maxOrdering = 0
      project.story_attributes.each {|attrib|maxOrdering = maxOrdering >= attrib.ordering ? maxOrdering : attrib.ordering}
      StoryAttribute.create(:project_id => project.id, :name => "Lead Time", :value_type => StoryAttribute::Number, :is_custom => false, :show => false, :width => 90, :ordering => maxOrdering + 10)
      StoryAttribute.create(:project_id => project.id, :name => "Cycle Time", :value_type => StoryAttribute::Number, :is_custom => false, :show => false, :width => 90, :ordering => maxOrdering + 20)
    end
  end

  def self.down
    StoryAttribute.find(:all, :conditions => {:name => "Lead Time", :is_custom => false}).each do |story_attribute|
      story_attribute.destroy
    end
    StoryAttribute.find(:all, :conditions => {:name => "Cycle Time", :is_custom => false}).each do |story_attribute|
      story_attribute.destroy
    end
  end
end