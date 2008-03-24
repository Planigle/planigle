class IndividualsController < ApplicationController
  before_filter :login_required, :except => :activate
  before_filter :find_individual, :only => %w(show edit update destroy)

  # Display the current individuals.
  # GET /individuals
  # GET /individuals.xml
  def index
    @individuals = Individual.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @individuals }
    end
  end

  # Provide a form to create a new individual.
  # GET /individuals/new
  # GET /individuals/new.xml
  def new
    @individual = Individual.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @individual }
    end
  end

  # Create a new Individual.  Generate an email so that they can validate their address.
  # POST /individuals
  # POST /individuals.xml
  def create
    @individual = Individual.new(params[:individual])

    respond_to do |format|
      if @individual.save
        flash[:notice] = "An email has been sent to validate the individual's email address.  The link enclosed in the email must be visited before the individual can log in."
        format.html { redirect_to(@individual) }
        format.xml  { render :xml => @individual, :status => :created, :location => @individual }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @individual.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Allow the user to activate himself/herself by clicking on an email link.
  # GET /activate/<activation code>
  def activate    
    if (individual = Individual.activate(params[:activation_code]))
      individual.save(false)
    end
    redirect_back_or_default('/')
  end

  # Show the information for an individual.
  # GET /individuals/1
  # GET /individuals/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @individual }
    end
  end

  # Provide a form to edit an individual.
  # GET /individuals/1/edit
  def edit
  end

  # Update an individual.
  # PUT /individuals/1
  # PUT /individuals/1.xml
  def update
    respond_to do |format|
      if @individual.update_attributes(params[:individual])
        flash[:notice] = 'Individual was successfully updated.'
        format.html { redirect_to(@individual) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @individual.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete an individual.
  # DELETE /individuals/1
  # DELETE /individuals/1.xml
  def destroy
    @individual.destroy

    respond_to do |format|
      format.html { redirect_to(individuals_url) }
      format.xml  { head :ok }
    end
  end

  private

  # Prepare the instance by finding the specified individual.
  def find_individual
    @individual = Individual.find( params[ :id ] )
  end
end
