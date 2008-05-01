# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Give a little more space for the name and restrict its length.
  def name_form_column(record, input_name)
    text_field :record, :name, :name => input_name, :size => 40, :maxlength => 40
  end

  # Give a little more space for the description.
  def description_form_column(record, input_name)
    text_area :record, :description, :name => input_name, :rows => 8, :cols => 120
  end
  
  # Answer a string to represent the project.
  def project_id_column(record)
    h(record.project.name)
  end

  # Answer a hash mapping projects to their ids.
  def project_mapping
    Project.find(:all, :order => 'name').collect {|project| [h(project.name), project.id]}
  end
    
  # Override how we select project.
  def project_id_form_column(record, input_name)
    select :record, :project_id, project_mapping, :name => input_name
  end

  NoOwner = 'No Owner'
  
  # Answer a string to represent the owner.
  def individual_id_column(record)
    (individual=record.individual) ? h(individual.name) : NoOwner
  end

  # Answer a hash mapping individuals to their ids.
  def individual_mapping
    mapping = individuals.collect {|individual| [h(individual.name), individual.id]}
    mapping << [NoOwner, nil]
    mapping
  end
  
  # Answer the individuals to use.
  def individuals
    project_id = controller.project_id
    project_id ? Individual.find(:all, :conditions => ['project_id = ?', project_id], :order=>'first_name, last_name') : Individual.find(:all, :order=>'first_name, last_name')
  end
    
  # Override how we select owner.
  def individual_id_form_column(record, input_name)
    select :record, :individual_id, individual_mapping, :name => input_name
  end

  NoIteration = 'Backlog'

  # Answer a string to represent the iteration.
  def iteration_id_column(record)
    (iteration=record.iteration) ? h(iteration.name) : NoIteration
  end

  # Answer a hash mapping iterations to their ids.
  def iteration_mapping
    project_id = controller.project_id
    iterations = project_id ? Iteration.find(:all, :conditions => ['project_id = ?', project_id], :order => 'start') : Iteration.find(:all, :order=>'start')
    mapping = iterations.collect {|iteration| [h(iteration.name), iteration.id]}
    mapping << [NoIteration, nil]
    mapping
  end
    
  # Override how we select owner.
  def iteration_id_form_column(record, input_name)
    select :record, :iteration_id, iteration_mapping, :name => input_name
  end

  # Override the export columns to use label rather than name.
  def format_export_column_header_name(column)
    column.label.titleize
  end
end