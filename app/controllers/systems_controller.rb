class SystemsController < ResourceController
  before_filter :login_required, :except => :summarize

  # Summarize the system data.
  # GET /summarize
  def summarize
    System.summarize
    render :xml => xml_result('Recent data has now been summarized.')
  end

  # Return the system data.
  # GET /report
  def report
    respond_to do |format|
      format.xml { render :xml => data, :status => :success }
      format.amf { render :amf => data }
    end
  end

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
  
  # Answer the reporting data
  def data
    report_data = {}
    report_data['release_totals'] = ReleaseTotal.find(:all, :conditions => ['releases.project_id = ?', project_id], :joins => :release)
    report_data['release_breakdowns'] = Release.find(:all, :conditions => {:project_id => project_id}).inject([]) {|collect, release| collect.concat(CategoryTotal.summarize_for(release))}
    report_data['iteration_totals'] = IterationTotal.find(:all, :conditions => ['iterations.project_id = ?', project_id], :joins => :iteration)
    report_data['iteration_velocities'] = IterationVelocity.find(:all, :conditions => ['iterations.project_id = ?', project_id], :joins => :iteration)
    report_data['iteration_breakdowns'] = Iteration.find(:all, :conditions => {:project_id => project_id}).inject([]) {|collect, iteration| collect.concat(CategoryTotal.summarize_for(iteration))}
    report_data
  end
end