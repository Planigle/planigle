class IterationsController < ApplicationController
  before_filter :login_required
  before_filter :find_iteration, :only => %w(show edit update destroy)

  # Display the current iterations.
  # GET /iterations
  # GET /iterations.xml
  def index
    find_all_iterations

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @iterations }
    end
  end

  # Provide a form to create a new iteration.
  # GET /iterations/new
  # GET /iterations/new.xml
  def new
    @iteration = Iteration.new_based_on_previous
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @iteration }
    end
  end

  # Create a new Iteration.  Generate an email so that they can validate their address.
  # POST /iterations
  # POST /iterations.xml
  def create
    respond_to do |format|
      if request.xhr?
        Iteration.new_based_on_previous.save(false)
        find_all_iterations
        format.html { render :partial => 'iterations' }
      else
        @iteration = Iteration.new(params[:iteration])
        if @iteration.save
          format.html { redirect_to(iterations_path) }          
          format.xml  { render :xml => @iteration, :status => :created, :location => @iteration }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @iteration.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # Show the information for an iteration.
  # GET /iterations/1
  # GET /iterations/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @iteration }
    end
  end

  # Provide a form to edit an iteration.
  # GET /iterations/1/edit
  def edit
  end

  # Update an iteration.
  # PUT /iterations/1
  # PUT /iterations/1.xml
  def update
    respond_to do |format|
      if @iteration.update_attributes(params[:iteration])
        format.html { redirect_to(iterations_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @iteration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete an iteration.
  # DELETE /iterations/1
  # DELETE /iterations/1.xml
  def destroy
    @iteration.destroy

    respond_to do |format|
      if (request.xhr?)
        find_all_iterations
        format.html { render :partial => 'iterations' }
      else
        format.html { redirect_to(iterations_url) }        
      end
      format.xml  { head :ok }
    end
  end

  private

  # Find all iterations
  def find_all_iterations
    @iterations = Iteration.find(:all, :order=>'start')
  end

  # Prepare the instance by finding the specified iteration.
  def find_iteration
    @iteration = Iteration.find( params[ :id ] )
  rescue
    respond_to do |format|
      if (request.xhr?)
        find_all_iterations
        format.html { render :partial => 'iterations', :status => 404 }
      else
        flash[:notice] = 'Invalid id'
        format.html { redirect_to(iterations_url) }
      end
      format.xml  { render :xml => xml_error('Invalid id'), :status => 404 }
    end
  end
end