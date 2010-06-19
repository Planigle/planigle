class AddId < ActiveRecord::Migration
  def self.up
    Project.find_with_deleted(:all).each do |project|
      StoryAttribute.create(:project_id => project.id, :name => "Id", :value_type => StoryAttribute::String, :is_custom => false, :show => false, :width => 60, :ordering => 5)
    end
  end

  def self.down
    StoryAttribute.find_with_deleted(:all, :conditions => {:name => "Id", :is_custom => false}).each do |story_attribute|
      story_attribute.destroy
    end
  end
end