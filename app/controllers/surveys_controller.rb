class SurveysController < ApplicationController
  # Create a survey template.
  def show
    project = Project.find(:first, :conditions => [ "survey_key = ? and survey_mode != 0", params[:id]])
    if !project
      render :xml => xml_error("Invalid survey key")
    else
      render :xml => project.create_survey
    end
  end
  
  # Post a survey template.
  def update
    project = Project.find(:first, :conditions => [ "survey_key = ? and survey_mode != 0", params[:id]])
    if !project
      render :xml => xml_error("Invalid survey key")
    else
      begin
        Survey.transaction do
          # Create Survey / clear existing entries for this email
          if (@survey = Survey.find(:first, :conditions => [ "project_id = ? and STRCMP( email, ?)=0", project.id, params[:email] ]))
            @survey.survey_mappings.delete_all
          else
            @survey = Survey.new(:project_id => project.id, :email => params[:email])
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
          render :xml => xml_error('Error processing survey')
        else
          render :xml => @survey.errors, :status => :unprocessable_entity
        end
      end
    end
  end
end