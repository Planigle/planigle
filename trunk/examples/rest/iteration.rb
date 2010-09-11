# To interact with iterations on Planigle, use code like:
#   iteration = Iteration.create(:name => 'Iteration 1', :start => '9/1/2009', :finish => '9/15/2009')
#
#   iterations = Iteration.find(:all)
#
#   iteration.retrospective_results = 'TBD'
#   iteration.save
#
#   iteration.destroy
#
# See resource.rb in this directory for more information on interacting with Planigle via REST.
#
# See attr_accessible in /app/models/iteration.rb for a list of allowed fields.

class Iteration < Resource
end