# To interact with releases on Planigle, use code like:
#   release = Release.create(:name => 'Boondoggle', :start => '9/1/2009', :finish => '12/15/2009')
#
#   releases = Release.find(:all)
#
#   release.name = 'Fred'
#   release.save
#
#   release.destroy
#
# See resource.rb in this directory for more information on interacting with Planigle via REST.
#
# See attr_accessible in /app/models/release.rb for a list of allowed fields.

class Release < Resource
end