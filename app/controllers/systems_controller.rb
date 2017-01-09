class SystemsController < ResourceController
  before_action :login_required, :except => :summarize

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

  # Return the report data for the specified release.
  # GET /report_release
  def report_release
    respond_to do |format|
      format.xml { render :xml => data_release, :status => :success }
      format.amf { render :amf => data_release }
    end
  end

  # Return the report data for the specified iteration.
  # GET /report_iteration
  def report_iteration
    respond_to do |format|
      format.xml { render :xml => data_iteration, :status => :success }
      format.amf { render :amf => data_iteration }
    end
  end

protected

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
  
  # Answer the reporting data for the last 4 iterations and last release.
  def data
    report_data = {}
    last4Iterations = Iteration.find(:all, :limit => 4, :order => 'start desc', :include => [{:stories => :story_values},:project], :conditions => ['iterations.project_id = ? and start < now()', project_id])
    last4IterationIds = last4Iterations.collect{|iteration| iteration.id}
    lastRelease = Release.find(:all, :limit => 1, :order => 'start desc', :conditions => ['releases.project_id = ? and start < now()', project_id])
    lastReleaseIds = lastRelease.collect{|release| release.id}
    report_data['iteration_totals'] = IterationTotal.find(:all, :conditions => ['iterations.id in (?)', last4IterationIds], :joins => :iteration)
    report_data['iteration_story_totals'] = IterationStoryTotal.find(:all, :conditions => ['iterations.id in (?)', last4IterationIds], :joins => :iteration)
    report_data['release_totals'] = ReleaseTotal.find(:all, :conditions => ['releases.id in (?)', lastReleaseIds], :joins => :release)
    report_data['iteration_breakdowns'] = last4Iterations.inject([]) {|collect, iteration| collect.concat(CategoryTotal.summarize_for(iteration))}
    report_data['release_breakdowns'] = lastRelease.inject([]) {|collect, release| collect.concat(CategoryTotal.summarize_for(release))}
    report_data['iteration_velocities'] = IterationVelocity.find(:all, :conditions => ['iterations.project_id = ?', project_id], :joins => :iteration)
    report_data
  end
  
  # Answer the reporting data for the specified release.
  def data_release
    report_data = {}
    release_id = params[:release_id]
    release = Release.find(release_id)
    if (release != nil && release.project_id == project_id)
      report_data['release_totals'] = ReleaseTotal.find(:all, :conditions => ['release_id = ?', release_id])
      report_data['release_breakdowns'] = CategoryTotal.summarize_for(release)
    end
    report_data
  end
  
  # Answer the reporting data for the specified iteration.
  def data_iteration
    report_data = {}
    iteration_id = params[:iteration_id]
    iteration = Iteration.find(iteration_id)
    if (iteration != nil && iteration.project_id == project_id)
      report_data['iteration_totals'] = IterationTotal.find(:all, :conditions => ['iteration_id = ?', iteration_id])
      report_data['iteration_story_totals'] = IterationStoryTotal.find(:all, :conditions => ['iteration_id = ?', iteration_id])
      report_data['iteration_breakdowns'] = CategoryTotal.summarize_for(iteration)
    end
    report_data
  end
  
private
  def record_params
    params.require(:record).permit(:license_agreement)
  end
end