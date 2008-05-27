# WRB - Added new type of filter.
class Enumeration < ActiveScaffold::DataStructures::ListFilter

	# Return a list of conditions based on the params 
	def conditions(params)
    return ["#{@options[:column]} IN (?)", params]
	end
	
  # Answer a mapping of keys to values (could be an array of pairs, rather than a hash to allow ordering).
  def mapping()
    @options[:mapping]
  end
end
