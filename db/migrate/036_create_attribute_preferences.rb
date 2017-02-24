class CreateAttributePreferences < ActiveRecord::Migration[4.2]
  def self.up
    add_column :story_attributes, :is_custom, :boolean, :null => false, :default => true
    add_column :story_attributes, :width, :integer, :null => false
    add_column :story_attributes, :ordering, :decimal, :precision => 9, :scale => 5
    add_column :story_attributes, :show, :boolean, :null => false, :default => false
    StoryAttribute.reset_column_information # Work around an issue where the new columns are not in the cache.
    Project.with_deleted.each do |project|
      i = 140
      project.story_attributes.each do |attrib|
        attrib.attributes = {:is_custom => true, :width => (attrib.value_type == StoryAttribute::Number ? 65 : 135), :ordering => i, :show => false}
        attrib.save( :validate=> false )
        i += 10
      end
      project.add_default_attributes
      project.save( :validate=> false )
    end
  end

  def self.down
    StoryAttribute.delete_all(:is_custom => false)
    remove_column :story_attributes, :is_custom
    remove_column :story_attributes, :width
    remove_column :story_attributes, :ordering
    remove_column :story_attributes, :show
  end
end
