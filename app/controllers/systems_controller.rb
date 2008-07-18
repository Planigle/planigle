class SystemsController < ResourceController
  before_filter :login_required

protected

  # Return all records.
  def get_records
    System.find(:all)
  end

  # Answer the current record.
  def get_record
    System.find(:first)
  end
  
  # You cannot create new instances.
  def create_record
    System.find(:first)
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @license_changed = @record.license_agreement != params[0].license_agreement
      @record.license_agreement = params[0].license_agreement
    else
      @license_changed = params[:record] && @record.license_agreement != params[:record][:license_agreement]
      @record.attributes = params[:record]
    end
  end

  # Save the record (answering whether it was successful
  def save_record
    begin
      System.transaction do
        if @record.save && @license_changed
          Individual.update_all( :accepted_agreement => nil )
          true
        else
          false
        end        
      end
    rescue Exception => e
      if @record.valid?
        logger.error(e)
        logger.error(e.backtrace.join("\n"))
      end
      false
    end
  end
end