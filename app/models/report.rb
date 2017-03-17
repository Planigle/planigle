class Report

  attr_reader :params, :current_individual
    
  # Answer team reporting data
  def team_totals
    last3Iterations = lastIterations
    if last3Iterations.length > 0
      result = ActiveRecord::Base.connection.exec_query(\
        velocity_query(last3Itertions)
      )
      result.to_a
    else
      []
    end
  end
  
  def upcoming_iterations
    last3Iterations = lastIterations
    if last3Iterations.length > 0
      result = ActiveRecord::Base.connection.exec_query(\
        'SELECT iterations.id as iteration_id, iterations.name as iteration_name, teams.id as team_id, teams.name as team_name, SUM(IFNULL(stories.effort,0)) as planned, teams.velocity '\
        'FROM iterations '\
        'JOIN (' + velocity_query(last3Iterations) + ') teams '\
        'LEFT JOIN stories ON stories.iteration_id=iterations.id AND stories.team_id=teams.id '\
        'WHERE iterations.finish > now() '\
        'AND iterations.project_id=' + Integer(project_id).to_s + ' '\
        'GROUP by iterations.id, teams.id '\
        'ORDER by iterations.start, teams.name '
      )
      result.to_a
    else
      []
    end
  end
  
  def iteration_metrics
    query = 'iterations.project_id = :project_id'
    values = {project_id: project_id}
    if params[:team_id]
      query += ' and iteration_velocities.team_id ' + (params[:team_id] == '' ? 'IS NULL' : ' = :team_id')
      if params[:team_id] != ''
        values[:team_id] = params[:team_id] == '' ? nil : params[:team_id]
      end
    end
    velocities = group_iteration_velocities(IterationVelocity.where(query, values).joins(:iteration).includes(:iteration).order('iterations.finish'))
  end
  
  def iteration_totals
    report_data = {}
    iteration = Iteration.find(params[:iteration_id])
    if iteration and iteration.project_id == project_id
      query = 'iterations.id = :iteration_id AND iterations.start <= date AND iterations.finish >= date'
      query_params = {iteration_id: params[:iteration_id]}
      if params[:team_id] != nil
        if params[:team_id] == ''
          query += ' AND team_id IS NULL'
        else
          query += ' AND team_id=:team_id'
          query_params[:team_id] = params[:team_id] == '' ? nil : params[:team_id]
        end
      end
      report_data['totals'] = group_totals(IterationTotal.where(query, query_params).joins(:iteration))
      report_data['story_totals'] = group_totals(IterationStoryTotal.where(query, query_params).joins(:iteration))
      teamId = 'All'
      if params[:team_id]
        teamId = params[:team_id] == '' ? nil : Integer(params[:team_id])
      end
      report_data['breakdowns'] = CategoryTotal.summarize_for(iteration, teamId)
    end
    report_data
  end
  
  # Answer the reporting data for the specified release.
  def release_totals
    report_data = {}
    release = Release.find(params[:release_id])
    if release and release.project_id == project_id
      query = 'releases.id = :release_id AND releases.start <= date AND releases.finish >= date'
      query_params = {release_id: params[:release_id]}
      if params[:team_id] != nil
        if params[:team_id] == ''
          query += ' AND team_id IS NULL'
        else
          query += ' AND team_id=:team_id'
          query_params[:team_id] = params[:team_id] == '' ? nil : params[:team_id]
        end
      end
      report_data['totals'] = group_totals(ReleaseTotal.where(query, query_params).joins(:release))
      teamId = 'All'
      if params[:team_id]
        teamId = params[:team_id] == '' ? nil : Integer(params[:team_id])
      end
      report_data['breakdowns'] = CategoryTotal.summarize_for(release, teamId)
    end
    report_data
  end

private

  def velocity_query(last3Iterations)
    last3IterationIds = last3Iterations.collect{|iteration| iteration.id}
    numIterations = last3IterationIds.length
    teamId = params[:team_id] ? (params[:team_id] == '' ? 0 : Integer(params[:team_id]).to_s) : nil
    return \
      'SELECT IFNULL(teams.id,0) AS id, IFNULL(teams.name,"None") AS name, SUM(IFNULL(stories.effort,0)) / ' + numIterations.to_s + ' AS velocity, SUM(IFNULL(tt.estimate,0)) / ' + numIterations.to_s + ' AS utilization '\
      'FROM stories '\
      'LEFT JOIN teams ON teams.id=stories.team_id '\
      'LEFT JOIN ('\
        'SELECT stories.id, SUM(estimate) AS estimate '\
        'FROM stories '\
        'JOIN tasks ON tasks.story_id = stories.id '\
        'WHERE ' + (params[:team_id] ? ('IFNULL(stories.team_id,0)=' + teamId) : 'stories.project_id=' + Integer(project_id).to_s) + ' '\
        'AND stories.iteration_id IN (' + last3IterationIds.join(',') + ') '\
        'AND stories.status_code=3 '\
        'AND stories.deleted_at IS NULL '\
        'AND tasks.deleted_at IS NULL '\
        'GROUP BY stories.id '\
      ') tt ON tt.id=stories.id '\
      'WHERE ' + (teamId ? ('stories.team_id=' + teamId) : 'stories.project_id=' + Integer(project_id).to_s) + ' '\
      'AND stories.iteration_id IN (' + last3IterationIds.join(',') + ') '\
      'AND stories.status_code=3 '\
      'AND stories.deleted_at IS NULL '\
      'GROUP BY teams.id '
  end
  
  def lastIterations
    Iteration.where('project_id = :project_id and finish < now()', {project_id: project_id}).order('finish desc').limit(3)
  end
  
  def group_iteration_velocities(velocities)
    filtered = []
    mapping = {}
    velocities.each do |velocity|
      if mapping[velocity.iteration_id]
        current = mapping[velocity.iteration_id]
        current.attempted += velocity.attempted
        current.completed += velocity.completed
        current.lead_time += velocity.lead_time
        current.cycle_time += velocity.cycle_time
        current.num_stories += velocity.num_stories
      else
        mapping[velocity.iteration_id] = velocity
        filtered << velocity
      end
    end
    filtered
  end  

  def group_totals(totals)
    filtered = []
    mapping = {}
    totals.each do |total|
      if mapping[total.date]
        current = mapping[total.date]
        current.created += total.created
        current.in_progress += total.in_progress
        current.blocked += total.blocked
        current.done += total.done
      else
        mapping[total.date] = total
        filtered << total
      end
    end
    filtered
  end

  def project_id
    current_individual ? current_individual.project_id : nil
  end

  def initialize(attributes)
    @params = attributes[:params]
    @current_individual = attributes[:current_individual]
  end
end