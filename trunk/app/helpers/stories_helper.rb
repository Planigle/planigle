module StoriesHelper
  # Allow users to change the story status
  def selectStory(story)
    id = "story"
    url = url_for(:controller => 'stories', :action => 'update', :id => story.id)
    selectItem(story, id, url, story.status_code)
  end

  # Allow users to change the task status
  def selectTask(task)
    id = "task_#{task.id.to_s}"
    url = url_for(:controller => 'tasks', :action => 'update', :story_id=> task.story.id, :id => task.id)
    selectItem(task.story, id, url, task.status_code)
  end

private
  
  def selectItem(story, id, url, status_code)
    status = Story.valid_status_values[status_code]
    if story.authorized_for_update?(current_individual)
      select_tag = "<select
        id='#{id}'
        onchange=\"changeStatus('#{url}',#{id}.selectedIndex)\">"
      Story.valid_status_values.each do |state|
        select_tag << "<option#{state == status ? ' selected' : ''}>#{state}</option>"
      end
      select_tag << '</select>'
    else
      status
    end
  end
end