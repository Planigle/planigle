class IterationsController < ResourceController
  before_filter :login_required

protected

  # Get the records based on the current individual.
  def get_records
    if current_individual.role >= Individual::ProjectAdmin or project_id
      Iteration.find(:all, :conditions => ["project_id = ?", project_id], :order => 'start')
    else
      Iteration.find(:all, :order => 'start')
    end
  end

  # Answer the current record based on the current individual.
  def get_record
    Iteration.find(is_amf ? params[0] : params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    is_amf ? params[0] : Iteration.new(params[:record])
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @record.name = params[0].name
      @record.start = params[0].start
      @record.length = params[0].length
    else
      @record.attributes = params[:record]
    end
  end
end