class CategoryTotal

  attr_reader :category, :total

  # Summarize an object and return the instances (do not persist).
  def self.summarize_for(object, team_id)
    attribs = object.project.story_attributes.select {|attrib| attrib.value_type >= StoryAttribute::List}
    values = {}
    object.stories.each do |story|
      if story.effort && story.effort > 0 && story.team_id == team_id
        attribs.each {|attrib| put(values, attrib.name, story.team_id, story.name_for(attrib), story.effort)}
      end
    end
    collect = {}
    values.keys.each do |attrib_name|
      values[attrib_name].keys.each do |team_id|
        values[attrib_name][team_id].keys.each do |category|
          if collect[attrib_name] == nil
            collect[attrib_name] = []
          end
          collect[attrib_name] << self.new(:category => category, :total => values[attrib_name][team_id][category])
        end
      end
    end
    collect
  end

protected
  
  def self.put(hash, attrib_name, team_id, category, amount)
    if !hash[attrib_name]
      hash[attrib_name] = {}
    end
    team_id = team_id ? team_id : ""
    if !hash[attrib_name][team_id]
      hash[attrib_name][team_id] = {}
    end
    category = category ? category : "None"
    if !hash[attrib_name][team_id][category]
      hash[attrib_name][team_id][category] = 0
    end
    hash[attrib_name][team_id][category] += amount
  end
  
  def initialize(attributes)
    @category = attributes[:category]
    @total = attributes[:total]
  end
end