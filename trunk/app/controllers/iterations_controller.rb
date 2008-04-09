class IterationsController < ApplicationController
  before_filter :login_required
  active_scaffold do |config|
    config.columns = [:name, :start, :length ]
    config.columns[:length].label = 'Length (in weeks)' 
    config.list.sorting = {:start => 'ASC'}
    config.nested.add_link('Stories', [:stories])
  end
end