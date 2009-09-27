# To interact with individuals on Planigle, use code like:
#   individual = Individual.create(:login => 'test', :password => 'tool', :password_confirmation => 'tool', :first_name => 'testy',
#     :last_name => 'user', :email => 'testy@example.com', :role => 2, :notification_type => 0)
#
#   individuals = Individual.find(:all)
#
#   individual.enabled = false
#   individual.save
#
#   individual.destroy
#
# See remote.rb in this directory for more information on interacting with Planigle via REST.
#
# See attr_accessible in /app/models/individual.rb for a list of allowed fields.  That file also contains information on allowed
# roles and notification types.

class Individual < Resource
end