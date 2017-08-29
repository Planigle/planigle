require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  fixtures :individuals
  fixtures :stories
  fixtures :comments

  # Test that a comment can be created.
  def test_create_comment
    assert_difference 'Comment.count' do
      comment = create_comment
      assert !comment.new_record?, "#{comment.errors.full_messages.to_sentence}"
    end
  end

  # Test that you can't create a comment without a story.
  def test_create_comment_without_story
    assert_no_difference 'Comment.count' do
      comment = Comment.create({:message => 'foo'})
    end
  end
  
  # Test the validation of message.
  def test_message
    validate_field(:message, false, nil, 20480)
  end

private

  # Create a comment with valid values.  Options will override default values (should be :attribute => value).
  def create_comment(options = {})
    Comment.create({ :story_id => 1, :individual_id => 1, :message => 'foo', :ordering => 1 }.merge(options))
  end
end
