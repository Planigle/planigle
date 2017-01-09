class ErrorsController < ResourceController
  before_action :login_required

protected

  # Create a new record given the params.
  def create_record
    params[:record][:individual_id] = current_individual.id
    params[:record][:time] = Time.new
    Error.new(params[:record])
  end
  

  # Answer if this request is authorized for create.
  def authorized_for_create?(record)
    true
  end

  # Answer if this request is authorized for read.
  def authorized_for_read?(record)
    false
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    false
  end

  # Answer if this request is authorized for delete.
  def authorized_for_destroy?(record)
    false
  end
  
private
  def record_params
    params.require(:record).permit(:time, :message, :stack_trace, :individual_id)
  end
end