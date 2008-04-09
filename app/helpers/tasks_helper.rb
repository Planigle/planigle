module TasksHelper
  # Map user displayable terms to the internal status codes (in this case, they're the same).
  def status_code_mapping
    Task.valid_status_values.collect { |val| [val, val] }
  end
    
  # Override how we select status.
  def status_code_form_column(record, input_name)
    select :record, :individual_id, status_code_mapping, :name => input_name
  end

  # Answer a string to represent the status.
  def status_code_column(record)
    record.status
  end
end
