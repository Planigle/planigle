class CommentsController < ResourceController
  before_action only: [:index, :show] do
    log_in_or_oauth :read
  end
  before_action only: [:create, :update, :destroy] do
    log_in_or_oauth :backlog
  end

  # Notify of key changes.
  def create
    super
    if @record && @record.story
      @record.story.send_notification(current_individual, "New Comment from " + current_individual.name + " on " + @record.story.name, email_body(@record.story))
    end
  end

  # Notify of key changes.
  def update
    super
    if @record && @record.story
      @record.story.send_notification(current_individual, "Updated Comment from " + current_individual.name + " on " + @record.story.name, email_body(@record.story))
    end
  end

protected

  def email_body(story)
    '<pre>' + @record.message + '</pre>' + '<br><p>To respond to this comment, click here: ' + story.link + '.</p>'
  end

  # Answer descriptor for this type of object
  def record_type
    "Comment"
  end

  # Get the records based on the current individual.
  def get_records
    Comment.where(story_id: params[:story_id]).order(ordering: :asc)
  end

  # Answer the current record based on the current individual.
  def get_record
    comment = Comment.find_by(id: params[:id], story_id: params[:story_id])
    if !comment; raise ActiveRecord::RecordNotFound.new; end
    comment
  end
  
  # Create a new record given the params.
  def create_record
    comment = Comment.new(record_params)
    comment.story_id = params[:story_id]
    comment.individual = current_individual
    comment.ordering = comment.story.comments.length + 1
    comment
  end
  
  # Update the record given the params.
  def update_record
    @record.attributes = record_params
  end
  
private
  def record_params
    params.require(:record).permit(:message)
  end
end