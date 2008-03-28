class StoriesController < ApplicationController
  before_filter :login_required
  before_filter :find_story, :only => %w(show edit update destroy)

  # List the current stories.
  # GET /stories
  # GET /stories.xml
  def index
    find_all_stories
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stories }
    end
  end

  # Sort the stories (specify the new order by listing the story ids in the desired order).
  # GET /stories/sort_stories
  # GET /stories/sort_stories.xml
  def sort_stories
    respond_to do |format|
      @stories = Story.sort(params[:stories])
      @stories.each { |story| story.save(false) }
      
      format.html { render :partial => 'stories' }
      format.xml  { render :xml => @stories }
    end
  rescue Exception => e
    @stories = find_all_stories
    respond_to do |format|
      format.html { render :partial => 'stories', :status => :unprocessable_entity }
      format.xml  { render :xml => xml_error('Invalid id'), :status => :unprocessable_entity }
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
        format.html { redirect_to(stories_path) }
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
        format.html { redirect_to(stories_path) }
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
      if (request.xhr?)
        find_all_stories
        format.html { render :partial => 'stories' }
      else
        format.html { redirect_to(stories_url) }        
      end
      format.xml  { head :ok }
    end
  end

  private

  # Find all stories
  def find_all_stories
    @stories = Story.find(:all, :order=>'priority')
  end

  # Prepare the instance by finding the specified story.
  def find_story
    @story = Story.find( params[ :id ] )
  rescue
    respond_to do |format|
      if (request.xhr?)
        find_all_stories
        format.html { render :partial => 'stories', :status => 404 }
      else
        flash[:notice] = 'Invalid id'
        format.html { redirect_to(stories_url) }
      end
      format.xml  { render :xml => xml_error('Invalid id'), :status => 404 }
    end
  end
end
