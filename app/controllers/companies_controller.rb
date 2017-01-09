class CompaniesController < ResourceController
  before_action :login_required, :except => :create
  before_action :login_or_signup_required, :only => :create

  # POST /companies
  # POST /companies.xml
  def create
    if params[:individual]
      respond_to do |format|
        begin
          Company.transaction do
            @record = create_record
            @project = Project.new(params[:project])
            @project.company_id = @record.id ? @record.id : 0 # To prevent company must be set error
            @individual = Individual.new(params[:individual])
            @individual.company_id = @record.id ? @record.id : 0 # To prevent company must be set error
            @individual.projects << @project # To prevent project must be set error
            @individual.role = Individual::ProjectAdmin
            if @record.valid? and @project.valid? and @individual.valid? and @record.projects << @project and @record.individuals << @individual and @record.save
              format.xml { render :xml => '<?xml version="1.0" encoding="UTF-8"?><records>' + @record.to_xml(:skip_instruct => true) + @individual.to_xml(:skip_instruct => true) + "</records>", :status => :created }
              format.amf { render :amf => [@record, @individual] }
            else
              raise ActiveRecord::RecordNotSaved
            end
            CompanyMailer.signup_notification( @record, @project, @individual ).deliver_now
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
            @project = Project.new(params[:project])          
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

  # Answer whether records have changed.
  def have_records_changed(time)
    Company.have_records_changed(current_individual, time)
  end

  # Get the records based on the current individual.
  def get_records
    Company.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    Company.find(params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    Company.new(params[:record])
  end
  
  # Update the record given the params.
  def update_record
    @record.attributes = record_params
  end
  
  # Update the project given the params.
  def update_project
    @project.attributes = params[:project]
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_premium_expiry = params[:record][:premium_expiry]
    new_premium_limit = params[:record][:premium_limit]
    if (current_individual.role > Individual::Admin && new_premium_expiry && record.premium_expiry != (new_premium_expiry.class == Date ? new_premium_expiry : Date.parse(new_premium_expiry)))
      false # Must be admin to change premium_expiry
    elsif (current_individual.role > Individual::Admin && new_premium_limit && record.premium_limit != new_premium_limit.to_i)
      false # Must be admin to change premium_limit
    else
      super
    end
  end

private

  def record_params
    params.require(:record).permit(:name, :premium_limit, :premium_expiry, :last_notified_of_expiration)
  end
end