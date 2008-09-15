class ProjectsController < ResourceController
  before_filter :login_required, :except => :create
  before_filter :login_or_signup_required, :only => :create

  # POST /projects
  # POST /projects.xml
  def create
    if params[:individual] && params[:individual].include?( :login )
      respond_to do |format|
        begin
          @record = create_record          
          @record.transaction do
            @individual = is_amf ? params[1] : Individual.new(params[:individual])
            @individual.project_id = @record.id ? @record.id : 0 # To prevent project must be set error.
            @individual.role = Individual::ProjectAdmin
            if @record.valid? and @individual.valid? and @record.individuals << @individual and @record.save
              format.xml { render :xml => '<?xml version="1.0" encoding="UTF-8"?><records>' + @record.to_xml(:skip_instruct => true) + @individual.to_xml(:skip_instruct => true) + "</records>", :status => :created }
              format.amf { render :amf => [@record, @individual] }
            else
              raise ActiveRecord::RecordNotSaved;
            end
          end
        rescue Exception => e
          format.xml { render :xml => merge_errors(@record, @individual), :status => :unprocessable_entity }
          format.amf { render :amf => @record.errors.full_messages.concat(@individual.errors.full_messages) }
        end
      end
    else
      super
    end
  end

protected

  # Merge the errors from the project and individal on signup.
  def merge_errors(project, individual)
    errors = project.errors.full_messages.concat(individual.errors.full_messages)
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.instruct!
    builder.errors {|e| errors.each { |msg| e.error(msg)}}
  end

  # For creating projects, you either need to be logged in or it needs to be a signup.
  def login_or_signup_required
    (params[:individual] && params[:individual].include?( :login )) || login_required
  end

  # Get the records based on the current individual.
  def get_records
    Project.get_records(current_individual)
  end

  # Answer the current record based on the current individual.
  def get_record
    Project.find(is_amf ? params[0] : params[:id])
  end
  
  # Create a new record given the params.
  def create_record
    is_amf ? params[0] : Project.new(params[:record])
  end
  
  # Update the record given the params.
  def update_record
    if is_amf
      @record.name = params[0].name
      @record.description = params[0].description
      @record.survey_mode = params[0].survey_mode
    else
      @record.attributes = params[:record]
    end
  end

  # Answer if this request is authorized for update.
  def authorized_for_update?(record)
    new_premium_expiry = is_amf ? params[0].premium_expiry : params[:record][:premium_expiry]
    new_premium_limit = is_amf ? params[0].premium_limit : params[:record][:premium_limit]
    if (current_individual.role > Individual::Admin && new_premium_expiry && record.premium_expiry != (new_premium_expiry.class == Date ? new_premium_expiry : Date.parse(new_premium_expiry)))
      false # Must be admin to change premium_expiry
    elsif (current_individual.role > Individual::Admin && new_premium_limit && record.premium_limit != new_premium_limit.to_i)
      false # Must be admin to change premium_limit
    else
      super
    end
  end
end