module TasksHelper
  # Give a little more space for the name and restrict its length.
  def name_form_column(record, input_name)
    text_field :record, :name, :name => input_name, :size => 40, :maxlength => 40
  end

  # Give a little more space for the description.
  def description_form_column(record, input_name)
    text_area :record, :description, :name => input_name, :rows => 10, :cols => 150
  end

  # Reduce space for the effort.
  def effort_form_column(record, input_name)
    text_field :record, :effort, :name => input_name, :size => 4
  end

  # Map user displayable terms to the internal status codes.
  def status_code_mapping
    Task.status_code_mapping
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
