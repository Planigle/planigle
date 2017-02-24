# See http://api.rubyonrails.org/files/vendor/rails/activeresource/README.html for general usage of ActiveResource to do REST.
# Specific examples are given in the other classes in this directory.
#
# Be sure to change username and password below to match your credentials.

gem 'activeresource', '= 2.0.2'
require 'activesupport'
require 'activeresource'

class Resource < ActiveResource::Base
  self.site="http://username:password@www.planigle.com/planigle/"

  def as_json(options = {})
    options[:root] = :record
    super(options)
  end

  def id_from_response(response)
    response.id
  end
end