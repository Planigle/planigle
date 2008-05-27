class Association < ActiveScaffold::DataStructures::ListFilter

	# Return a list of conditions based on the params 
	def conditions(params)
		association = association_tree[association_tree.size - 1]
		column = [association.active_record.table_name, association.primary_key_name].join('.')

    # WRB - Changed so that '' is interepreted to be null.
    if params.detect {|param| param == ''}
      params = params.select {|param| param != '' }
      return ["(#{column} is null or #{column} IN (?))", params]
    else
      return ["#{column} IN (?)", params]
    end
	end
	
	def association_tree()
		arr ||= association_tree_from_array(@core.model, @options[:association]).reverse
		return arr
	end
	
  # WRB - Added to check if nil is allowed.
  def allow_nil()
    @options[:allow_nil] ? @options[:allow_nil] : false
  end
  
  # WRB - Added to return the label to use for nil (if it is allowed).
  def nil_label()
    @options[:nil_label] ? @options[:nil_label] : 'None'
  end
  
	private
	
	def association_tree_from_array(model, association_array)
		arr = []
		association_array.each do |model_name|
			association = model.reflect_on_all_associations.detect {|assoc| assoc.name.to_s == model_name.to_s}
			arr << association
			model = association.klass
		end
		return arr.reverse
	end
	
end
