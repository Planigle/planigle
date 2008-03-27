class Iteration < ActiveRecord::Base
  validates_presence_of     :name, :start
  validates_length_of       :name,    :within => 1..40  
  validates_numericality_of :length, :allow_nil => true

  # Create a new iteration based on the most recent one.
  def self.new_based_on_previous()
    iteration = self.new
    last_iteration = self.find(:first, :order=>'start desc')
    if last_iteration
      tail = last_iteration.name.split.last
      if tail.to_i != 0
        iteration.name = last_iteration.name.chomp(tail) << (tail.to_i + 1).to_s
      end
      iteration.start = last_iteration.start + last_iteration.length * 7
      iteration.length = last_iteration.length
    end
    iteration
  end
end
