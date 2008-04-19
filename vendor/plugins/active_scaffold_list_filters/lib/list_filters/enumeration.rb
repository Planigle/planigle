# WRB - Added new type of filter.
class Enumeration < ActiveScaffold::DataStructures::ListFilter

	# Return a list of conditions based on the params 
	def conditions(params)
    if params.detect {|param| param == ''}
      params = params.select {|param| param != '' }
      return ["#{@options[:column]} is null or #{@options[:column]} IN (?)", params]
    else
      return ["#{@options[:column]} IN (?)", params]
    end
	end
	
  # Answer a mapping of keys to values (could be an array of pairs, rather than a hash to allow ordering).
  def mapping()
    @options[:mapping]
  end
end
