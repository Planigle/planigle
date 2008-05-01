module IndividualsHelper
  All = 'All'
  
  # Answer a string to represent the project.
  def project_id_column(record)
    (project=record.project) ? h(project.name) : All
  end

  # Answer a hash mapping projects to their ids.
  def project_mapping
    mapping = Project.find(:all, :order=>'name').collect {|project| [h(project.name), project.id]}
    mapping << [All, nil]
    mapping
  end
    
  # Override how we select project.
  def project_id_form_column(record, input_name)
    select :record, :project_id, project_mapping, :name => input_name
  end

  # Give a little more space for the login and restrict its length.
  def login_form_column(record, input_name)
    text_field :record, :login, :name => input_name, :size => 40, :maxlength => 40
  end

  # Override how we enter password.
  def password_form_column(record, input_name)
    password_field :record, :password, :name => input_name, :size => 40, :maxlength => 40
  end

  # Override how we enter password confirmation.
  def password_confirmation_form_column(record, input_name)
    password_field :record, :password_confirmation, :name => input_name, :size => 40, :maxlength => 40
  end

  # Give a little more space for the email and restrict its length.
  def email_form_column(record, input_name)
    text_field :record, :email, :name => input_name, :size => 100, :maxlength => 100
  end

  # Give a little more space for the first name and restrict its length.
  def first_name_form_column(record, input_name)
    text_field :record, :first_name, :name => input_name, :size => 40, :maxlength => 40
  end

  # Give a little more space for the last name and restrict its length.
  def last_name_form_column(record, input_name)
    text_field :record, :last_name, :name => input_name, :size => 40, :maxlength => 40
  end
    
  # Override how we select enabled (to prevent nil).
  def enabled_form_column(record, input_name)
    select :record, :enabled, [['True', true], ['False', false]], :name => input_name
  end
end