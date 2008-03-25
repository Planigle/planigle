class Story < ActiveRecord::Base
  validates_presence_of     :name
  validates_length_of       :name,                   :within => 1..40
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true
  validates_length_of       :acceptance_criteria,    :maximum => 4096, :allow_nil => true
  validates_numericality_of :effort, :allow_nil => true
  validates_inclusion_of    :status_code,            :in => [0, 1 , 2]

  StatusMapping = [ 'Created', 'In Progress', 'Accepted' ]

  # Answer the valid values for status.
  def self.valid_status_values()
    StatusMapping
  end

  # Answer my status.
  def status()
    StatusMapping[status_code]
  end

  # Set status.
  def status=(status)
    self.status_code = StatusMapping.index(status)
  end

  # Override to_xml to exclude private attributes.
  def to_xml(options = {})
    if !options[:except]
      options[:except] = [:status_code]
    end
    if !options[:methods]
      options[:methods] = [:status]
    end
    super(options)
  end
end
