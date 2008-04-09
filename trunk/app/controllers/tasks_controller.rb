class TasksController < ApplicationController
  before_filter :login_required
  before_filter :capture_parent
  around_filter :update_js, :only=>[:create, :update, :destroy]

  active_scaffold do |config|
    config.columns = [:name, :individual_id, :effort, :status_code ]
    config.columns[:individual_id].label = 'Owner'
    config.columns[:status_code].label = 'Status'
    config.create.columns = [:name, :description, :individual_id, :effort, :status_code, :story_id ]
    config.show.columns = [:name, :description, :individual_id, :effort, :status_code ]
    config.update.columns = [:name, :description, :individual_id, :effort, :status_code ]
  end

private

  # Add in Javascript to cause the containing story to be updated.
  def update_js
    if request.xhr?
      js = render_to_string :partial => 'update_story', :layout => false
    end
    yield
    if request.xhr?
      response.body << js
    end
  end
  
  # Keep track of my parent (if I have one).  This is used in my helper methods.
  def capture_parent
    @parent_id = active_scaffold_constraints[:story]
    if @parent_id
      @iteration_id = Story.find(@parent_id).iteration_id.to_s
    end
  end
end
