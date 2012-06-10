class AddEpicAttribute < ActiveRecord::Migration
  def self.up
    Project.find_with_deleted(:all).each do |project|
      attrib = project.story_attributes.find(:first, :conditions => {:name=>"Name"})
      ordering = attrib == nil ? 15 : attrib.ordering
      StoryAttribute.create(:project_id => project.id, :name => "Epic", :value_type => StoryAttribute::List, :is_custom => false, :show => false, :width => 200, :ordering => ordering - 1)
    end
  end

  def self.down
    StoryAttribute.find(:all, :conditions => {:name => "Epic", :is_custom => false}).each do |story_attribute|
      story_attribute.destroy
    end
  end
end