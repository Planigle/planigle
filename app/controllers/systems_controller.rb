class SystemsController < ResourceController
  before_action :login_required, :except => :summarize

  # Summarize the system data.
  # GET /summarize
  def summarize
    System.summarize
    render :json => {reponse: 'Recent data has now been summarized.'}
  end

  # Return the report totals for the specified iteration.
  # GET /report_iteration_totals
  def report_iteration_totals
    render :json => new_report.iteration_totals
  end
  
  # Return the report totals for the specified release.
  # GET /report_release_totals
  def report_release_totals
    render :json => new_report.release_totals
  end
  
  # Return the teams totals for the last 3 iterations.
  # GET /report_team_totals
  def report_team_totals
    render :json => new_report.team_totals
  end
  
  # Return information about upcoming iterations.
  # GET /report_upcoming_iterations
  def report_upcoming_iterations
    render :json => new_report.upcoming_iterations
  end
  
  # Return information about all iterations.
  # GET /report_upcoming_iterations
  def report_iteration_metrics
    render :json => new_report.iteration_metrics
  end

protected

  def new_report
    Report.new(:params => params, :current_individual => current_individual)
  end

  # Return all records.
  def get_records
    System.find(:all)
  end

  # Answer the current record.
  def get_record
    System.first
  end
  
  # You cannot create new instances.
  def create_record
    System.first
  end
  
  # Update the record given the params.
  def update_record
    @license_changed = params[:record] && @record.license_agreement != params[:record][:license_agreement]
    @record.attributes = params[:record]
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

private
  
  def record_params
    params.require(:record).permit(:license_agreement)
  end
end