# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  NoOwner = 'No Owner'

  # Answer a string to use if there is no owner.
  def no_owner
    NoOwner
  end
  
  # Answer a string to represent the owner.
  def individual_id_column(record)
    (individual=record.individual) ? h(individual.name) : NoOwner
  end

  # Answer a hash mapping individuals to their ids.
  def individual_mapping
    mapping = Individual.find(:all, :order=>'first_name, last_name').collect {|individual| [h(individual.name), individual.id]}
    mapping << [NoOwner, nil]
    mapping
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
    mapping = Iteration.find(:all, :order=>'start').collect {|iteration| [h(iteration.name), iteration.id]}
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