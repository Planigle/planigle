class SurveysController < ApplicationController
  before_filter :login_required, :except => [:new, :create]

  # Create a survey template.
  def new
    project = Project.find(:first, :conditions => [ "id = ? and survey_key = ? and survey_mode != 0", params[:project_id], params[:survey_key]])
    if !project
      render :xml => xml_error("Invalid survey key"), :status => :unprocessable_entity
    else
      render :xml => project.create_survey
    end
  end
  
  # Post a survey template.
  def create
    project = Project.find(:first, :conditions => [ "id = ? and survey_key = ? and survey_mode != 0", params[:project_id], params[:survey_key]])
    if !project
      render :xml => xml_error("Invalid survey key"), :status => :unprocessable_entity
    else
      begin
        Survey.transaction do
          # Create Survey / clear existing entries for this email
          if (@survey = Survey.find(:first, :conditions => [ "project_id = ? and STRCMP( email, ?)=0", project.id, params[:email] ]))
            @survey.name = params[:name]
            @survey.company = params[:company]
            @survey.survey_mappings.delete_all
          else
            @survey = Survey.new(:project_id => project.id, :name => params[:name], :company => params[:company], :email => params[:email])
            @survey.save!
          end
    
          # Add new entries
          priority = 1
          params[:stories].each do |story|
            @survey.survey_mappings << SurveyMapping.new(:story_id => story, :priority => priority)
            priority += 1
          end
          @survey.save!

          # Update the user rankings on the stories
          @survey.apply_to_stories.each do |story|
            story.save!
          end
          
          render :xml => "Survey submitted successfully!  Thanks for your help."
        end
      rescue Exception => e
        if @survey.valid?
          logger.error(e)
          logger.error(e.backtrace.join("\n"))
          render :xml => xml_error('Error processing survey'), :status => 500
        else
          render :xml => @survey.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # List the existing surveys.
  def index
    project = Project.find(params[:project_id])
    render :xml => project.surveys.to_xml(:include => [])
  end

  # Show details on a particular survey
  def show
    survey = Project.find(params[:project_id]).surveys.find(params[:id])
    render :xml => survey
  end

  # Update the survey (currently can only mark as excluded)
  def update
    survey = Project.find(params[:project_id]).surveys.find(params[:id])
    if params.has_key?(:record) and params[:record].has_key?(:excluded)
      begin
        Survey.transaction do
          excluded = params[:record][:excluded] == "true"
          survey.excluded = excluded
          survey.save!
  
          # Update the user rankings on the stories
          ranked_stories = survey.apply_to_stories
          ranked_stories.each do |story|
            story.save!
          end
          
          # nil out user_priority for stories that are no longer ranked.
          if excluded
            survey.stories.each do |story|
              if !ranked_stories.include? story
                story.user_priority = nil
                story.save!
              end
            end
          end
      
          render :xml => survey
        end
      rescue Exception => e
        if survey.valid?
          logger.error(e)
          logger.error(e.backtrace.join("\n"))
          render :xml => xml_error('Error processing survey'), :status => 500
        else
          render :xml => survey.errors, :status => :unprocessable_entity
        end
      end
    else
      render :xml => xml_error('Can only change whether a survey is excluded'), :status => :unprocessable_entity
    end
  end
end