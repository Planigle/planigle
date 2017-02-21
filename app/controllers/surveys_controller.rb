class SurveysController < ApplicationController
  before_action :login_required, :except => [:new, :create]

  require 'cgi'

  # Create a survey template.
  def new
    project = Project.find(:first, :conditions => [ "survey_key = ? and survey_mode != 0", params[:survey_key]])
    if !project || !project.company.is_premium
      render :json => {error: "Invalid survey key"}, :status => :unprocessable_entity
    else
      render :json => project.create_survey
    end
  end
  
  # Post a survey template.
  def create
    project = Project.find(:first, :conditions => [ "survey_key = ? and survey_mode != 0", params[:survey_key]])
    if !project || !project.company.is_premium
      render :json => {error: "Invalid survey key"}, :status => :unprocessable_entity
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
            if story.to_s.include? ','
              match = story.match(/(.*),(.*)/)
              name = "User suggestion: " + CGI::unescape(match[1])
              description = "Suggested by " + params[:name] + " (" + params[:email] + ")" + (params[:company] ? " of " + params[:company] : "") + "\r" + CGI::unescape(match[2])
              story = Story.create(:project_id=>project.id, :name=>name,:description=>description, :is_public=>false).id
            end
            @record.survey_mappings << SurveyMapping.new(:story_id => story, :priority => priority)
            priority += 1
          end
          @record.save!

          # Update the user rankings on the stories
          @record.apply_to_stories.each do |story|
            story.save!
          end
          
          render :json => "Survey submitted successfully!  Thanks for your help."
        end
      rescue Exception => e
        if @record.valid?
          logger.error(e)
          logger.error(e.backtrace.join("\n"))
          render :json => {error: 'Error processing survey'}, :status => 500
        else
          render :json => @record.errors, :status => :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

  # List the existing surveys.
  def index
    @records = project_id ? Survey.where(project_id: project_id) : Survey.all
    render :json => @records.to_json(:include => [])
  end

  # Show details on a particular survey
  def show
    @record = Survey.includes([survey_mappings: [:story]]).find(params[:id])
    if @record.authorized_for_read?(current_individual)
      render :json => @record
    else
      unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

  # Update the survey (currently can only mark as excluded)
  def update
    @record = Survey.find(params[:id])
    if @record.authorized_for_update?(current_individual)
      if params.has_key?(:record) and params[:record].has_key?(:excluded)
        begin
          Survey.transaction do
            excluded = params[:record][:excluded]
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
        
            render :json => @record
          end
        rescue Exception => e
          if @record.valid?
            logger.error(e)
            logger.error(e.backtrace.join("\n"))
            render :json => {error: 'Error processing survey'}, :status => 500
          else
            render :json => @record.errors, :status => :unprocessable_entity
          end
        end
      else
        render :json => {error: 'Can only change whether a survey is excluded'}, :status => :unprocessable_entity
      end
    else
      unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end
  
private
  def record_params
    params.require(:record).permit(:project_id, :name, :company, :email, :excluded)
  end
end