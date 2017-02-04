class CategoryTotal

  attr_reader :id, :story_attribute_id, :team_id, :category, :total

  # Summarize an object and return the instances (do not persist).
  def self.summarize_for(object)
    attribs = object.project.story_attributes.select {|attrib| attrib.value_type >= StoryAttribute::List}
    values = {}
    object.stories.each do |story|
      if story.effort && story.effort > 0
        attribs.each {|attrib| put(values, attrib.id, story.team_id, story.value_for(attrib), story.effort)}
      end
    end
    collect = []
    values.keys.each do |attrib_id|
      values[attrib_id].keys.each do |team_id|
        values[attrib_id][team_id].keys.each do |category|
          collect << self.new(:id => object.id, :team_id => (team_id == "" ? nil : team_id), :story_attribute_id => attrib_id, :category => (category == "" ? "null" : category.to_s), :total => values[attrib_id][team_id][category])
        end
      end
    end
    collect
  end

protected
  
  def self.put(hash, attrib_id, team_id, category, amount)
    if !hash[attrib_id]
      hash[attrib_id] = {}
    end
    team_id = team_id ? team_id : ""
    if !hash[attrib_id][team_id]
      hash[attrib_id][team_id] = {}
    end
    category = category ? category : ""
    if !hash[attrib_id][team_id][category]
      hash[attrib_id][team_id][category] = 0
    end
    hash[attrib_id][team_id][category] += amount
  end
  
  def initialize(attributes)
    @id = attributes[:id]
    @team_id = attributes[:team_id]
    @story_attribute_id = attributes[:story_attribute_id]
    @category = attributes[:category]
    @total = attributes[:total]
  end
end