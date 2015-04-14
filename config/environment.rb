# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Planigle::Application.initialize!

# Require will_paginate gem
require "will_paginate" 

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below
Mime::Type.register "application/x-amf", :amf

# The following code is a work-around for the Flash 8 bug that prevents our multiple file uploader
# from sending the _session_id.  Here, we hack the Session#initialize method and force the session_id
# to load from the query string via the request uri. (Tested on Lighttpd, Mongrel, Apache)
class CGI::Session
  alias original_initialize initialize
  def initialize(request, option = {})
    if (!option[:cookie_only])
      session_key = option['session_key'] || '_session_id'
      query_string = if (qs = request.env_table["QUERY_STRING"]) and qs != ""
        qs
      elsif (ru = request.env_table["REQUEST_URI"][0..-1]).include?("?")
        ru[(ru.index("?") + 1)..-1]
      end
      query_string = query_string ? CGI.unescape(query_string).sub('%25', '%') : query_string # need to un url encode; for some reason it is not catching %25 -> %
      if query_string and query_string.include?(session_key)
        option['session_id'] = query_string.scan(/#{session_key}=(.*?)(&.*?)*$/).flatten.first
      end
    end
    original_initialize(request, option)
  end
end

# Override CookieStore to use the session id (which might be from a parameter instead of the cookie).
class CGI::Session::CookieStore
  def read_cookie
    query_string = if (qs = @session.cgi.env_table["QUERY_STRING"]) and qs != ""
      qs
    elsif (ru = @session.cgi.env_table["REQUEST_URI"][0..-1]).include?("?")
      ru[(ru.index("?") + 1)..-1]
    end
    query_string = query_string ? CGI.unescape(query_string).sub('%25', '%') : query_string # need to un url encode; for some reason it is not catching %25 -> %
    if query_string and query_string.include?("_planigle_session_id")
      @session.session_id
    else
      @session.cgi.cookies[@cookie_options['name']].first
    end
  end
end

# This works around http://code.whytheluckystiff.net/syck/ticket/24 until it gets fixed..
class BigDecimal
  alias :_original_to_yaml :to_yaml
  def to_yaml (opts={},&block)
    to_s.to_yaml(opts,&block)
  end
end

# Add expiration headers for static content (see http://thebogles.com/blog/2008/02/enabling-browser-caching-of-static-content-in-mongrel/).
if defined? Mongrel::DirHandler
  module Mongrel
    class DirHandler
      def send_file_with_expires(req_path, request, response, header_only=false)
        lower = req_path.downcase
        if lower.include?(".gif") || lower.include?(".jpg") || lower.include?(".png")
          response.header['Cache-Control'] = 'max-age=604800, public, must-revalidate' #week
        else
          response.header['Cache-Control'] = 'max-age=3600, public, must-revalidate' #hour
        end
        response.header['Expires'] = (Time.now + 10.years).rfc2822
        send_file_without_expires(req_path, request, response, header_only)
      end
      alias_method :send_file_without_expires, :send_file
      alias_method :send_file, :send_file_with_expires
    end
  end
end