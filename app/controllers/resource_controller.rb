class ResourceController < ApplicationController

  # GET /records
  def index
    @records = get_records
    render :json => @records
  end
  
  # GET /records/1
  def show
    @record = get_record
    if (authorized_for_read?(@record))
      render :json => @record
    else
      unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

  # POST /records
  def create
    @record = create_record
    if (authorized_for_create?(@record))
      begin
        @record.class.transaction do
          if !@record.save
            raise "Errors creating"
          end
        end
        if record_visible
          render :json => @record, :status => :created
        else
          not_visible("created")
        end
      rescue Exception => e
        respond_to do |format|
          if @record.valid?
            logger.error(e)
            logger.error(e.backtrace.join("\n"))
            render :json => {:error => 'Error creating'}, :status => 500
          else
            render :json => @record.errors, :status => :unprocessable_entity
          end
        end
      end
    else
      unauthorized
    end
  end
  
  # PUT /records/1
  def update
    @record = get_record_for_change
    if (authorized_for_update?(@record))
      if (up_to_date(@record))
        begin
          @record.class.transaction do
            update_record
            if save_record
              post_update
            else
              raise "Errors updating"
            end
          end
          if record_visible
            render :json => @record
          else
            not_visible("updated")
          end
        rescue Exception => e
          if @record.valid?
            logger.error(e)
            logger.error(e.backtrace.join("\n"))
            render :json => {:error => 'Error updating'}, :status => 500
          else
            render :json => @record.errors, :status => :unprocessable_entity
          end
        end
      else
        out_of_date
      end
    else
      unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

  # DELETE /records/1
  def destroy
    @record = get_record_for_change
    if (authorized_for_destroy?(@record))
      @record.destroy
      render :json => @record
    else
      unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end
  
protected

  # Answer descriptor for this type of object
  def record_type
    "Object"
  end

  # Answer whether the resulting record is visible
  def record_visible
    true
  end

  # Save the record (answering whether it was successful
  def save_record
    @record.save
  end

  # Answer if this request is authorized for create.
  def authorized_for_create?(record)
    record.authorized_for_create?(current_individual)
  end

  # Answer if this request is authorized for read.
  def authorized_for_read?(record)
    record.authorized_for_read?(current_individual)
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    record.authorized_for_update?(current_individual)
  end

  # Answer if this request is authorized for delete.
  def authorized_for_destroy?(record)
    record.authorized_for_destroy?(current_individual)
  end
  
  # Some records make read only changes so need to be able to differentiate based on intention.
  def get_record_for_change
    get_record
  end
  
  # Some records make read only changes so need to be able to differentiate based on intention.
  def post_update
  end
  
  # Answer whether the record being changed is up to date.
  def up_to_date(record)
    timestamp = params[:updated_at]
    !timestamp || Time.parse(timestamp) == record.updated_at
  end

  # Send error that the record being changed is out of date.
  def out_of_date
    respond_with_warning("Someone else has made changes since you last refreshed.", "STALE")
  end

  # Send error that the record being changed is no longer visible.
  def not_visible(change)
    respond_with_warning(record_type + " was successfully " + change + ".  " + record_type + " does not show in list due to current filtering.", "FILTERED")
  end
  
  # Send warning.
  def respond_with_warning(warning, warning_id)
    status = 200
    render :json => {:errorId => warning_id, :error => warning, :record => @record}, :status => status
  end
end