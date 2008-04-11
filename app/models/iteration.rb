class Iteration < ActiveRecord::Base
  include Utilities::Text
  has_many :stories, :dependent => :nullify
  
  validates_presence_of     :name,   :start
  validates_length_of       :name,   :within => 1..40  
  validates_numericality_of :length, :allow_nil => true

  # Give intelligent defaults (based on iteration that is currently furthest out).
  def initialize(attributes={})
    last_iteration = self.class.find(:first, :order=>'start desc')
    if last_iteration
      if !attributes.include?(:name)
        attributes[:name] = increment_name(last_iteration.name)
      end
      if !attributes.include?(:start)
        attributes[:start] = last_iteration.start + last_iteration.length * 7
      end
      if !attributes.include?(:length)
        attributes[:length] = last_iteration.length
      end
    end
    super
  end
  
  # Override to_xml to include stories.
  def to_xml(options = {})
    if !options[:include]
      options[:include] = [:stories]
    end
    super(options)
  end
end
