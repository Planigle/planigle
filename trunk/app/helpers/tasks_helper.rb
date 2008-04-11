module TasksHelper
  # Map user displayable terms to the internal status codes (in this case, they're the same).
  def status_code_mapping
    i = -1
    Task.valid_status_values.collect { |val| i+=1;[val, i] }
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
    parent_string + 'tasks-active-scaffold'
  end

  # Override the scaffold content id to make it easier to reference more specifically.
  def active_scaffold_content_id
    parent_string + 'tasks-content'
  end

  # Override the body id to make it more friendly to Scriptaculous.
  def active_scaffold_tbody_id
    parent_string + 'tasks'
  end

  # Override the message id to make it more friendly to Scriptaculous.
  def empty_message_id
    parent_string + 'tasks-empty-message'
  end

  # Override the before header id to make it more friendly to Scriptaculous.
  def before_header_id
    parent_string + 'tasks-search-container'
  end

private

  # Answer a string representing my parent (ex. 19) if I have one.  If a parent exists, follow by
  # a - as a separator.
  def parent_string
    @parent_id ? @parent_id + '-' : ''
  end
end
