class ReleaseTotal < Total
  belongs_to :release
  
  # This should be overridden in subclasses.
  def self.id_field
    :release_id
  end
end