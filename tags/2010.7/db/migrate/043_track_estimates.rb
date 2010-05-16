class TrackEstimates < ActiveRecord::Migration
  def self.up
    add_column :projects, :track_actuals, :boolean, :null => false, :default => false
    add_column :tasks, :estimate, :decimal, :precision => 7, :scale => 2
    add_column :tasks, :actual, :decimal, :precision => 7, :scale => 2
    Task.reset_column_information # Work around an issue where the new columns are not in the cache.
    Task.find(:all).each do |task|
      task.estimate = task.effort
      if task.status_code == Story::Done
        task.effort = 0
      end
      task.save(false)
    end
    StoryAttribute.find(:all).each do |story_attribute|
      if !story_attribute.is_custom && story_attribute.name == "Time"
        story_attribute.name = "To Do"
        story_attribute.save(false)
      end
    end
    Project.find(:all).each do |project|
      max = 0
      project.story_attributes.each {|story_attribute| max = story_attribute.ordering > max ? story_attribute.ordering : max}
      StoryAttribute.create(:project_id => project.id, :name => "Estimate", :value_type => StoryAttribute::Number, :is_custom => false, :show => false, :width => 60, :ordering => max+10)
      StoryAttribute.create(:project_id => project.id, :name => "Actual", :value_type => StoryAttribute::Number, :is_custom => false, :show => false, :width => 50, :ordering => max+20)
    end
  end

  def self.down
    Task.find(:all).each do |task|
      task.effort = task.estimate
      task.save(false)
    end
    StoryAttribute.find(:all).each do |story_attribute|
      if !story_attribute.is_custom
        if story_attribute.name == "To Do"
          story_attribute.name = "Time"
          story_attribute.save(false)
        elsif story_attribute.name == "Estimate" || story_attribute.name == "Actual"
          story_attribute.destroy
        end
      end
    end
    remove_column :tasks, :actual
    remove_column :tasks, :estimate
    remove_column :projects, :track_actuals
  end
end