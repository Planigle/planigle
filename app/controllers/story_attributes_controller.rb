class StoryAttributesController < ResourceController
  before_filter :login_required

protected

  # Get the records based on the current individual.
  def get_records
    StoryAttribute.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    record = get_record_for_change
    record.show_for(current_individual)
    record
  end
  
  # Some records make read only changes so need to be able to differentiate based on intention.
  def get_record_for_change
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

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_project_id = is_amf ? params[0].project_id : params[:record][:project_id]
    if (new_project_id && record.project_id != new_project_id.to_i)
      false # Can't change project
    else
      super
    end
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      params[0].delete(:is_custom) # Can't edit is custom
      attributes = {:name => params[0].name, :value_type => params[0].value_type, :values => params[0].values, :ordering => params[0].ordering, :width => params[0].width, :show => params[0].show}
    else
      params[:record].delete(:is_custom)
      attributes = params[:record]
    end
    @record.update_for(current_individual, attributes)
  end
  
  # Some records make read only changes so need to be able to differentiate based on intention.
  def post_update
    @record.show_for(current_individual)
  end
  
private
  def record_params
    params.require(:record).permit(:project_id, :name, :value_type, :ordering, :is_custom, :show, :width)
  end
end