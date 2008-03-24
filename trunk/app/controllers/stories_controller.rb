class StoriesController < ApplicationController
  before_filter :login_required
  before_filter :find_story, :only => %w(show edit update destroy)

  # List the current stories.
  # GET /stories
  # GET /stories.xml
  def index
    @stories = Story.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stories }
    end
  end

  # Provide the form to create a new story.
  # GET /stories/new
  # GET /stories/new.xml
  def new
    @story = Story.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @story }
    end
  end

  # Create a new story.
  # POST /stories
  # POST /stories.xml
  def create
    @story = Story.new(params[:story])

    respond_to do |format|
      if @story.save
        flash[:notice] = 'Story was successfully created.'
        format.html { redirect_to(@story) }
        format.xml  { render :xml => @story, :status => :created, :location => @story }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Show the selected story.
  # GET /stories/1
  # GET /stories/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @story }
    end
  end

  # Provide a form to edit a story.
  # GET /stories/1/edit
  def edit
  end

  # Update a story.
  # PUT /stories/1
  # PUT /stories/1.xml
  def update
    respond_to do |format|
      if @story.update_attributes(params[:story])
        flash[:notice] = 'Story was successfully updated.'
        format.html { redirect_to(@story) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete a story.
  # DELETE /stories/1
  # DELETE /stories/1.xml
  def destroy
    @story.destroy

    respond_to do |format|
      format.html { redirect_to(stories_url) }
      format.xml  { head :ok }
    end
  end

  private

  # Prepare the instance by finding the specified story.
  def find_story
    @story = Story.find( params[ :id ] )
  end
end
