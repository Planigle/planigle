ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Set the current individual in the session from the individual fixtures.
  def login_as(individual)
    @request.session[:individual_id] = individual ? individual.id : nil
  end

  # Set the header for http authentication using the specified individual. 
  def authorize_as(individual)
    @request.env["HTTP_AUTHORIZATION"] = individual ? ActionController::HttpAuthentication::Basic.encode_credentials(individual.login, 'test') : nil
  end

  # Validate a text field.  If nullable, ensure it doesn't accept null as a value.
  # If min_size exists, make sure one under that fails and that one of the min_size works.
  # If max_size exists, make sure one over that fails and that one of the max_size works.
  def validate_field(field, nullable, min_size, max_size)
    if !nullable
      assert_failure(field, nil)
    end

    if min_size
      assert_failure(field, create_string(min_size-1))
      assert_success(field, create_string(min_size))
    end
  
    if max_size
      assert_success(field, create_string(max_size))
      assert_failure(field, create_string(max_size+1))
    end
  end

  # Assert that you can't set the field to the specified value.
  def assert_failure(field, value)
    assert_no_difference get_count do
      obj = send( create_object, field => value)
      assert obj.errors.on(field)
    end
  end

  # Assert that you can set the field to the specified value.
  def assert_success(field, value)
    assert_difference get_count do
      obj = send( create_object, field => value)
      assert !obj.new_record?, "#{obj.errors.full_messages.to_sentence}"
    end
  end

  # Create a string of the specified number of characters.
  def create_string(num_chars)
    str = ''
    (1..num_chars).each {|i| str = str << 'a'}
    str
  end

  # Assert that the XML for object includes the specified tag and value.
  def assert_tag( object, tag, value )
    includes = /.*<#{tag}.*>#{value}<\/#{tag}>.*/
    assert_match includes, object.to_xml
  end
  
  # Assert that the XML for object does not include the specified tag.
  def assert_no_tag( object, tag )
    includes = /.*<#{tag}.*>.*/
    assert_no_match includes, object.to_xml
  end

private

  # Log in as Flex would.
  def flex_login
    post '/session.xml', {:login => 'quentin', :password => 'testit'}, flex_header
  end

  # Answer the string to get the current count of this object.
  def get_count
    object_type << '.count'
  end

  # Answer the name of a method (created by developer in test class) to create an object for this test.
  # Ex., for Story, it would be create_story.  Quirk: if multiple words, there are no additional
  # underscores.  Ex., for TestCase, it would be create_testcase.
  # The method should create a version of the object that is valid.
  def create_object
    ('create_' << object_type.downcase).to_sym
  end

  # Answer a string representing the type of object. Ex., Story.
  def object_type
    self.class.to_s.chomp('Test').delete('_')
  end
  
  # Answer the header to use to show that flex is the client.
  def flex_header
    {'HTTP_X_FLASH_VERSION' => '9,0,115,0'}
  end

  # Answer the accept header that xml clients should end.
  def accept_header
    {'Accept' => 'text/xml'}
  end

  # Answer the authorization and accepts headers that xml clients should send.
  def authorization_header
    {'Authorization' => Base64.encode64('quentin' << ':' << 'testit'), 'Accept' => 'text/xml'}
  end
end
