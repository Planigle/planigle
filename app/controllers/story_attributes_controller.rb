class StoryAttributesController < ResourceController
  before_filter :login_required

protected

  # Get the records based on the current individual.
  def get_records
    StoryAttribute.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    StoryAttribute.find(is_amf ? params[0] : params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    if (!params[:record][:project_id])
      params[:record][:project_id] = current_individual.project_id
    end
    is_amf ? params[0] : StoryAttribute.new(params[:record])
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @record.name = params[0].name
      @record.value_type = params[0].value_type
      @record.values = params[0].values
    else
      @record.attributes = params[:record]
    end
  end
end