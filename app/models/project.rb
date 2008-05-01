class Project < ActiveRecord::Base
  has_many :individuals, :dependent => :destroy
  has_many :iterations, :dependent => :destroy
  has_many :stories, :dependent => :destroy

  validates_presence_of     :name
  validates_length_of       :name,                   :within => 1..40
  validates_length_of       :description,            :maximum => 4096, :allow_nil => true

  # Prevent a user from submitting a crafted form that bypasses activation
  # Anything that the user can change should be added here.
  attr_accessible :name, :description
end
