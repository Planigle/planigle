class SurveysController < ApplicationController
  before_filter :login_required, :except => [:new, :create]

  # Create a survey template.
  def new
    project = Project.find(:first, :conditions => [ "survey_key = ? and survey_mode != 0", params[:survey_key]])
    if !project
      render :xml => xml_error("Invalid survey key"), :status => :unprocessable_entity
    else
      render :xml => project.create_survey
    end
  end
  
  # Post a survey template.
  def create
    project = Project.find(:first, :conditions => [ "survey_key = ? and survey_mode != 0", params[:survey_key]])
    if !project
      render :xml => xml_error("Invalid survey key"), :status => :unprocessable_entity
    else
      begin
        Survey.transaction do
          # Create Survey / clear existing entries for this email
          if (@record = Survey.find(:first, :conditions => [ "project_id = ? and STRCMP( email, ?)=0", project.id, params[:email] ]))
            @record.name = params[:name]
            @record.company = params[:company]
            @record.survey_mappings.delete_all
          else
            @record = Survey.new(:project_id => project.id, :name => params[:name], :company => params[:company], :email => params[:email])
            @record.save!
          end
    
          # Add new entries
          priority = 1
          params[:stories].each do |story|
            @record.survey_mappings << SurveyMapping.new(:story_id => story, :priority => priority)
            priority += 1
          end
          @record.save!

          # Update the user rankings on the stories
          @record.apply_to_stories.each do |story|
            story.save!
          end
          
          render :xml => "Survey submitted successfully!  Thanks for your help."
        end
      rescue Exception => e
        if @record.valid?
          logger.error(e)
          logger.error(e.backtrace.join("\n"))
          render :xml => xml_error('Error processing survey'), :status => 500
        else
          render :xml => @record.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # List the existing surveys.
  def index
    @records = project_id ? Survey.find(:all, :conditions => ["project_id = ?", project_id]) : Survey.find(:all)
    render :xml => @records.to_xml(:include => [])
  end

  # Show details on a particular survey
  def show
    @record = Survey.find(params[:id])
    if @record.authorized_for_read?(current_individual)
      render :xml => @record
    else
      unauthorized
    end
  end

  # Update the survey (currently can only mark as excluded)
  def update
    @record = Survey.find(params[:id])
    if @record.authorized_for_update?(current_individual)
      if params.has_key?(:record) and params[:record].has_key?(:excluded)
        begin
          Survey.transaction do
            excluded = params[:record][:excluded] == "true"
            @record.excluded = excluded
            @record.save!
    
            # Update the user rankings on the stories
            ranked_stories = @record.apply_to_stories
            ranked_stories.each do |story|
              story.save!
            end
            
            # nil out user_priority for stories that are no longer ranked.
            if excluded
              @record.stories.each do |story|
                if !ranked_stories.include? story
                  story.user_priority = nil
                  story.save!
                end
              end
            end
        
            render :xml => @record
          end
        rescue Exception => e
          if @record.valid?
            logger.error(e)
            logger.error(e.backtrace.join("\n"))
            render :xml => xml_error('Error processing survey'), :status => 500
          else
            render :xml => @record.errors, :status => :unprocessable_entity
          end
        end
      else
        render :xml => xml_error('Can only change whether a survey is excluded'), :status => :unprocessable_entity
      end
    else
      unauthorized
    end
  end
end