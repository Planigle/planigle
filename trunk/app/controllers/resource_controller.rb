class ResourceController < ApplicationController

  # GET /records
  # GET /records.xml
  def index
    @records = get_records
    respond_to do |format|
      format.xml { render :xml => @records }
      format.amf { render :amf => @records }
    end
  end
  
  # GET /records/1
  # GET /records/1.xml
  def show
    @record = get_record
    if (authorized_for_read?(@record))
      respond_to do |format|
        format.iphone { render :layout => false }
        format.xml { render :xml => @record }
        format.amf { render :amf => @record }
      end
    else
      unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

  # POST /records
  # POST /records.xml
  def create
    @record = create_record
    if (authorized_for_create?(@record))
      respond_to do |format|
        begin
          @record.class.transaction do
            if @record.save
              format.xml { render :xml => @record, :status => :created }
              format.amf { render :amf => @record }
            else
              raise "Errors creating"
            end
          end
        rescue Exception => e
          if @record.valid?
            logger.error(e)
            logger.error(e.backtrace.join("\n"))
            format.xml { render :xml => xml_error('Error creating'), :status => 500 }
            format.amf { render :amf => 'Error creating' }
          else
            format.xml { render :xml => @record.errors, :status => :unprocessable_entity }
            format.amf { render :amf => @record.errors.full_messages }
          end
        end
      end
    else
      unauthorized
    end
  end
  
  # PUT /records/1
  # PUT /records/1.xml
  def update
    @record = get_record
    if (authorized_for_update?(@record))
      update_record
      respond_to do |format|
        begin
          @record.class.transaction do
            if save_record
              format.xml { render :xml => @record }
              format.amf { render :amf => @record }
            else
              raise "Errors updating"
            end
          end
        rescue Exception => e
          if @record.valid?
            logger.error(e)
            logger.error(e.backtrace.join("\n"))
            format.xml { render :xml => xml_error('Error updating'), :status => 500 }
            format.amf { render :amf => 'Error updating' }
          else
            format.xml { render :xml => @record.errors, :status => :unprocessable_entity }
            format.amf { render :amf => @record.errors.full_messages }
          end
        end
      end
    else
      unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

  # DELETE /records/1
  # DELETE /records/1.xml
  def destroy
    @record = get_record
    if (authorized_for_destroy?(@record))
      @record.destroy
      respond_to do |format|
        format.xml { render :xml => @record }
        format.amf { render :amf => @record }
      end
    else
      unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end
  
protected

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
end