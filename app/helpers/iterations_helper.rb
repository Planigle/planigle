module IterationsHelper
  # Give a little more space for the name and restrict its length.
  def name_form_column(record, input_name)
    text_field :record, :name, :name => input_name, :size => 40, :maxlength => 40
  end

  # Change the date picker to use a nice looking one.
  def start_form_column(record, input_name)
    calendar_date_select_tag 'record[start]', record.start, :embedded => false, :year_range => 2.years.ago..10.years.from_now
  end

  # Reduce space for the length.
  def length_form_column(record, input_name)
    text_field :record, :length, :name => input_name, :size => 3
  end
end
