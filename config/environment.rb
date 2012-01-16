# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :individual_observer, :error_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

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