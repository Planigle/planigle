module IndividualsHelper
  # Override how we enter password.
  def password_form_column(record, input_name)
    password_field :record, :password, :name => input_name
  end

  # Override how we enter password confirmation.
  def password_confirmation_form_column(record, input_name)
    password_field :record, :password_confirmation, :name => input_name
  end
    
  # Override how we select enabled (to prevent nil).
  def enabled_form_column(record, input_name)
    select :record, :enabled, [['True', true], ['False', false]], :name => input_name
  end
end