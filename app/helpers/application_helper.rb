# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Create a blank space using an image (For alignment purposes).
  def blank
    image_tag('blank.gif', :alt => '', :size => '11x11')
  end
end
