module StoriesHelper  
  # Map user displayable terms to the internal status codes (in this case, they're the same).
  def status_code_mapping
    i = -1
    Story.valid_status_values.collect { |val| i+=1;[val, i] }
  end
    
  # Override how we select status.
  def status_code_form_column(record, input_name)
    select :record, :status_code, status_code_mapping, :name => input_name
  end

  # Answer a string to represent the status.
  def status_code_column(record)
    record.status
  end

  # Override the scaffold id to make it easier to reference more specifically.
  def active_scaffold_id
    parent_string + 'stories-active-scaffold'
  end

  # Override the scaffold content id to make it easier to reference more specifically.
  def active_scaffold_content_id
    parent_string + 'stories-content'
  end

  # Override the body id to make it more friendly to Scriptaculous.
  def active_scaffold_tbody_id
    parent_string + 'stories'
  end

  # Override the message id to make it more friendly to Scriptaculous.
  def empty_message_id
    parent_string + 'stories-empty-message'
  end

  # Override the before header id to make it more friendly to Scriptaculous.
  def before_header_id
    parent_string + 'stories-search-container'
  end
  
  # Override the way that row ids are created to make it more friendly to Scriptaculous.
  def element_row_id(options = {})
    options[:id] ||= params[:id]
    clean_id("#{parent_string}story_#{options[:id]}")
  end
  
  # Create Javascript to allow the user to sort stories.
  # This is a modified form of the Scriptaculous code to update the table with the results.
  # It is particularly necessary due to the alternating colors.
  def make_sortable
    sortable_element active_scaffold_tbody_id,
      :onUpdate => "function(){new Ajax.Request('/stories/sort', {onSuccess: function(transport){Element.update(document.getElementById('#{active_scaffold_tbody_id}'), transport.responseText)}, asynchronous:true, evalScripts:true, parameters:Sortable.serialize('#{active_scaffold_tbody_id}')})}",
      :tag => 'tr',
      :url => {:action => 'sort'}
  end

private

  # Answer a string representing my parent (ex. 19) if I have one.  If a parent exists, follow by
  # a - as a separator.
  def parent_string
    @parent_id ? @parent_id + '-' : ''
  end
end