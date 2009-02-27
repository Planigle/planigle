class StoryAttributesController < ResourceController
  before_filter :login_required

protected

  # Get the records based on the current individual.
  def get_records
    StoryAttribute.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    StoryAttribute.find(is_amf ? params[0] : params[:id], :include => :story_attribute_values)
  end
  
  # Create a new record given the params.
  def create_record
    if (!params[:record][:project_id])
      params[:record][:project_id] = current_individual.project_id
    end
    is_amf ? params[0].delete(:is_custom) : params[:record].delete(:is_custom)
    is_amf ? params[0] : StoryAttribute.new(params[:record])
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      params[0].delete(:is_custom) # Can't edit is custom
      @record.name = params[0].name
      @record.value_type = params[0].value_type
      @record.values = params[0].values
    else
      params[:record].delete(:is_custom)
      @record.attributes = params[:record]
    end
  end
end