class Error < ActiveRecord::Base
  belongs_to :individual
 
  validates_presence_of     :individual_id, :time, :message, :stack_trace
  validates_length_of       :message,   :maximum => 256, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :stack_trace,   :maximum => 8192, :allow_nil => true # Allow nil to workaround bug
end