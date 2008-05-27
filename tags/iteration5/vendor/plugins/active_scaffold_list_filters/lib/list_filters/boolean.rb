# WRB - Added new type of filter.
class Boolean < ActiveScaffold::DataStructures::ListFilter

	# Return a list of conditions based on the params 
	def conditions(params)
    if params.length == 0
      ["0 = 1"]
    elsif params.length == 1
      params[0] == 'true' ? ["#{@options[:column]} = true"] : ["#{@options[:column]} = false"]
    else
      ["1 = 1"]
    end
	end
end
