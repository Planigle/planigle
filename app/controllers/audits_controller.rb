class AuditsController < ApplicationController
  before_action :login_required

  # GET /records?user_id=9999&type=<Story|Task|Release|Iteration|Project|Team|Individual>&start=yyyy-mm-dd&end=yyyy-mm-dd&object_id=9999
  # GET /records.xml?user_id=9999&type=<Story|Task|Release|Iteration|Project|Team|Individual>&start=yyyy-mm-dd&end=yyyy-mm-dd&object_id=9999
  def index
    if current_individual.role >= Individual::ProjectAdmin or project_id
      query = ['project_id = ?', project_id]
    else
      query = ['project_id = project_id']
    end
    query_params = params
    if query_params
      if query_params[:object_id]; query[0] += ' and auditable_id = ?'; query << query_params[:object_id]; end
      if query_params[:user_id]; query[0] += ' and user_id = ?'; query << query_params[:user_id]; end
      if query_params[:start]; query[0] += ' and created_at >= ?'; query << query_params[:start]; end
      if query_params[:end]; query[0] += ' and created_at <= ?'; query << query_params[:end]; end
      if query_params[:type]; query[0] += ' and auditable_type = ?'; query << query_params[:type]; end
    end
    @records = Audit.find(:all, :conditions => query, :order => 'created_at desc', :limit => 100)
    respond_to do |format|
      format.xml { render :xml => @records }
      format.amf { render :amf => @records }
    end
  end
  
  # GET /records/1
  # GET /records/1.xml
  def show
    @record = Audit.find(params[:id])
    if (authorized_for_read?(@record))
      respond_to do |format|
        format.xml { render :xml => @record }
        format.amf { render :amf => @record }
      end
    else
      unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end
  
protected

  def authorized_for_read?(record)
    current_individual.role == Individual::Admin or project_id == record.project_id
  end
end