class SystemsController < ResourceController
  before_action :login_required, :except => :summarize

  # Summarize the system data.
  # GET /summarize
  def summarize
    System.summarize
    render :json => {reponse: 'Recent data has now been summarized.'}
  end

  # Return the system data.
  # GET /report
  def report
    render :json => data
  end

  # Return the report data for the specified release.
  # GET /report_release
  def report_release
    render :json => data_release
  end

  # Return the report data for the specified iteration.
  # GET /report_iteration
  def report_iteration
    render :json => data_iteration
  end

  # Return the report totals for the last 4 iterations.
  # GET /report_iteration_totals
  def report_iteration_totals
    render :json => data_iteration_totals
  end
  
  # Return the teams totals for the last 3 iterations.
  # GET /report_team_totals
  def report_team_totals
    render :json => data_team_totals
  end

  # Return stats on work for current iteration.
  # GET /stats
  def stats
    if(current_individual.is_premium && current_individual.project != nil)
      render :json => Story.get_stats(current_individual, conditions)
    else
      render :json => []
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
  
  # Answer team reporting data
  def data_team_totals
    last3Iterations = Iteration.where('project_id = :project_id and finish < now()', {project_id: project_id}).order('finish desc').limit(3)
    last3IterationIds = last3Iterations.collect{|iteration| iteration.id}
    numIterations = last3IterationIds.length
    result = ActiveRecord::Base.connection.exec_query(\
      'SELECT IFNULL(teams.id,0) AS id, IFNULL(teams.name,"None") AS name, SUM(IFNULL(stories.effort,0)) / ' + numIterations.to_s + ' AS velocity, SUM(IFNULL(tt.estimate,0)) / ' + numIterations.to_s + ' AS utilization '\
      'FROM stories '\
      'LEFT JOIN teams ON teams.id=stories.team_id '\
      'LEFT JOIN ('\
        'SELECT stories.id, SUM(estimate) AS estimate '\
        'FROM stories '\
        'JOIN tasks ON tasks.story_id = stories.id '\
        'WHERE ' + (params[:team_id] ? ('IFNULL(stories.team_id,0)=' + Integer(params[:team_id]).to_s) : 'stories.project_id=' + Integer(project_id).to_s) + ' '\
        'AND stories.iteration_id IN (' + last3IterationIds.join(',') + ') '\
        'AND stories.status_code=3 '\
        'AND stories.deleted_at IS NULL '\
        'AND tasks.deleted_at IS NULL '\
        'GROUP BY stories.id '\
      ') tt ON tt.id=stories.id '\
      'WHERE ' + (params[:team_id] ? ('stories.team_id=' + Integer(params[:team_id]).to_s) : 'stories.project_id=' + Integer(project_id).to_s) + ' '\
      'AND stories.iteration_id IN (' + last3IterationIds.join(',') + ') '\
      'AND stories.status_code=3 '\
      'AND stories.deleted_at IS NULL '\
      'GROUP BY teams.id '
    )
    result.to_a
  end
  
  # Answer the reporting data for the last 4 iterations and last release.
  def data
    report_data = data_iteration_totals
    lastRelease = Release.where('releases.project_id = :project_id and start < now()', {project_id: project_id}).order('start desc').limit(1)
    lastReleaseIds = lastRelease.collect{|release| release.id}
    report_data['release_totals'] = ReleaseTotal.where('releases.id in (:ids)', {ids: lastReleaseIds}).joins(:release)
    report_data['release_breakdowns'] = lastRelease.inject([]) {|collect, release| collect.concat(CategoryTotal.summarize_for(release))}
    report_data['iteration_velocities'] = IterationVelocity.where('iterations.project_id = :project_id', {project_id: project_id}).joins(:iteration)
    report_data
  end
  
  def data_iteration_totals
    report_data = {}
    last4Iterations = Iteration.where('iterations.project_id = :project_id and start < now()', {project_id: project_id}).order('start desc').includes({stories: :story_values},:project).limit(4)
    last4IterationIds = last4Iterations.collect{|iteration| iteration.id}
    report_data['iteration_totals'] = IterationTotal.where('iterations.id in (:ids)', {ids: last4IterationIds}).joins(:iteration)
    report_data['iteration_story_totals'] = IterationStoryTotal.where('iterations.id in (:ids)', {ids: last4IterationIds}).joins(:iteration)
    report_data['iteration_breakdowns'] = last4Iterations.inject([]) {|collect, iteration| collect.concat(CategoryTotal.summarize_for(iteration))}
    report_data
  end
  
  # Answer the reporting data for the specified release.
  def data_release
    report_data = {}
    release_id = params[:release_id]
    release = Release.find(release_id)
    if (release != nil && release.project_id == project_id)
      report_data['release_totals'] = ReleaseTotal.where(release_id: release_id)
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
      report_data['iteration_totals'] = IterationTotal.where(iteration_id: iteration_id)
      report_data['iteration_story_totals'] = IterationStoryTotal.where(iteration_id: iteration_id)
      report_data['iteration_breakdowns'] = CategoryTotal.summarize_for(iteration)
    end
    report_data
  end
  
private
  def record_params
    params.require(:record).permit(:license_agreement)
  end
end