class AuditsController < ApplicationController
  AUDITS_PER_PAGE = 100
  before_action :login_required

  # GET /audits?user_id=9999&type=<Story|Task|Release|Iteration|Project|Team|Individual>&start=yyyy-mm-dd&end=yyyy-mm-dd&object_id=9999
  def index
    page = 1
    if params
      if params[:page]; page = params[:page]; end
    end
    @records = audit_query.order('created_at desc').paginate(:per_page=>AUDITS_PER_PAGE, :page=>page)
    @records.each{|audit| convert_audit(audit)}
    render :json => @records
  end
  
  # GET /audits/num_pages
  def num_pages
    count = audit_query.count
    puts count
    render :json => count == 0 ? 1 : (count.to_d / AUDITS_PER_PAGE).ceil
  end
  
  # GET /audits/1
  def show
    @record = Audited::Audit.find(params[:id])
    if (authorized_for_read?(@record))
      convert_audit(@record)
      render :json => @record
    else
      unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end
  
protected

  def audit_query
    query_params = {}
    if current_individual.role >= Individual::ProjectAdmin or project_id
      if params[:type] == 'Company'
        query = 'auditable_id = :company_id'
        query_params[:company_id] = current_individual.company_id
      else
        query = 'project_id = :project_id'
        query_params[:project_id] = project_id
      end
    else
      query = 'project_id = project_id'
    end
    if params
      if params[:object_id]; query += ' and auditable_id = :object_id'; query_params[:object_id] = params[:object_id]; end
      if params[:user_id]; query += ' and user_id = :user_id'; query_params[:user_id] = params[:user_id]; end
      if params[:start]; query += ' and created_at >= :start'; query_params[:start] = params[:start]; end
      if params[:end]; query += ' and created_at <= :end'; query_params[:end] = params[:end]; end
      if params[:type]; query += ' and auditable_type = :type'; query_params[:type] = params[:type]; end
    end
    Audited::Audit.where(query, query_params)
  end

  def convert_audit(audit)
    audit.audited_changes.each_pair do |key, values|
      if values.is_a?(String)
        values.gsub!("\r","<br>")
      elsif values.is_a?(Array)
        values.each do |value|
          if value && value.is_a?(String)
            value.gsub!("\r","<br>")
          end
        end
      end
    end
  end

  def authorized_for_read?(record)
    current_individual.role == Individual::Admin or project_id == record.project_id
  end
end