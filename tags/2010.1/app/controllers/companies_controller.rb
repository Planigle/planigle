class CompaniesController < ResourceController
  before_filter :login_required, :except => :create
  before_filter :login_or_signup_required, :only => :create

  # POST /companies
  # POST /companies.xml
  def create
    if params[:individual]
      respond_to do |format|
        begin
          Company.transaction do
            @record = create_record
            @project = is_amf ? params[1] : Project.new(params[:project])
            @project.company_id = @record.id ? @record.id : 0 # To prevent company must be set error
            @individual = is_amf ? params[2] : Individual.new(params[:individual])
            @individual.company_id = @record.id ? @record.id : 0 # To prevent company must be set error
            @individual.projects << @project # To prevent project must be set error
            @individual.role = Individual::ProjectAdmin
            if @record.valid? and @project.valid? and @individual.valid? and @record.projects << @project and @record.individuals << @individual and @record.save
              format.xml { render :xml => '<?xml version="1.0" encoding="UTF-8"?><records>' + @record.to_xml(:skip_instruct => true) + @individual.to_xml(:skip_instruct => true) + "</records>", :status => :created }
              format.amf { render :amf => [@record, @individual] }
            else
              raise ActiveRecord::RecordNotSaved
            end
          end
        rescue Exception => e
          format.xml { render :xml => merge_errors(@record, @project, @individual), :status => :unprocessable_entity }
          format.amf { render :amf => @record.errors.full_messages.concat(@project.errors.full_messages.concat(@individual.errors.full_messages)) }
        end
      end
    elsif params[:project]
      respond_to do |format|
        begin
          Company.transaction do
            @record = create_record
            @project = is_amf ? params[1] : Project.new(params[:project])          
            @project.company_id = @record.id ? @record.id : 0 # To prevent company must be set error
            if @record.valid? and @project.valid? and @record.projects << @project and @record.save
              format.xml { render :xml => @record, :status => :created }
              format.amf { render :amf => @record }
            else
              raise ActiveRecord::RecordNotSaved
            end
          end
        rescue Exception => e
          format.xml { render :xml => merge_errors(@record, @project), :status => :unprocessable_entity }
          format.amf { render :amf => @record.errors.full_messages.concat(@project.errors.full_messages) }
        end
      end
    else
      super
    end
  end

protected

  # Merge the errors from the company, project and individal on signup.
  def merge_errors(company, project, individual = nil)
    errors = company.errors.full_messages.concat(project.errors.full_messages)
    if individual
      errors = errors.concat(individual.errors.full_messages)
    end
    if errors.empty?
      errors.push("There was an error processing your request.  Please contact support.")
    end
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.instruct!
    builder.errors {|e| errors.each { |msg| e.error(msg)}}
  end

  # For creating companies, you either need to be logged in or it needs to be a signup.
  def login_or_signup_required
    params[:individual] || login_required
  end

  # Get the records based on the current individual.
  def get_records
    Company.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    Company.find(is_amf ? params[0] : params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    is_amf ? params[0] : Company.new(params[:record])
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @record.name = params[0].name
    else
      @record.attributes = params[:record]
    end
  end
  
  # Update the project given the params.
  def update_project
    if is_amf
      @project.name = params[1].name
      @project.description = params[1].description
      @project.survey_mode = params[1].survey_mode
    else
      @project.attributes = params[:project]
    end
  end
end