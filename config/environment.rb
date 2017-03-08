# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

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
    if query_string and query_string.include?("_planigle_session2_id")
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

# Modify what gets saved for Audits
module Audited::Auditor::AuditedInstanceMethods
  def write_audit(attrs)
     attrs[:associated] = send(audit_associated_with) unless audit_associated_with.nil?
     self.audit_comment = nil
     
     # Added part
     if self.class == StoryValue
       if (story_attribute.value_type == StoryAttribute::List || story_attribute.value_type == StoryAttribute::ReleaseList)
         if attrs[:action] == 'destroy'
           old_value = value ? StoryAttributeValue.where(id: value).first : nil
           changed_value = [old_value ? old_value.value : '', 'None']
         else
           old_value = changed_attributes['value'] ? StoryAttributeValue.find(changed_attributes['value']) : nil
           new_value = value ? StoryAttributeValue.find(value) : nil
           changed_value = [old_value ? old_value.value : 'None', new_value ? new_value.value : '']
         end
       else
         if attrs[:action] == 'destroy'
           changed_value = [value, nil]
         elsif attrs[:action] == 'update'
           changed_value = [changed_attributes['value'], value]
         else
           changed_value = [nil, value]
         end
       end
       if story
         attrs[:action]= 'update'
         attrs[:audited_changes] = {story_attribute.name => changed_value}
         attrs[:auditable_name] = story.name
         attrs[:project_id] = Thread.current[:user] ? Thread.current[:user].project_id : nil
         attrs[:user_id] = Thread.current[:user] ? Thread.current[:user].id : nil
         attrs[:username] = Thread.current[:user] ? Thread.current[:user].name : nil
         story.run_callbacks(:audit)  { story.audits.create(attrs) } if Story.auditing_enabled  # original
       end
     elsif !$auditing_disabled
       pr_id = respond_to?(:project_id) ? project_id : (Thread.current[:user] ? Thread.current[:user].project_id : nil)
       attrs[:auditable_name] = name
       attrs[:project_id] = pr_id
       attrs[:user_id] = Thread.current[:user] ? Thread.current[:user].id : nil
       attrs[:username] = Thread.current[:user] ? Thread.current[:user].name : nil
       run_callbacks(:audit)  { audits.create(attrs) } if auditing_enabled  # original
     end
   end
end

# Modify what gets sent via JSON for Audits
class Audited::Audit
  def user_name
    username
  end
  
  def as_json(options = {})
    if !options[:except]
      options[:except] = [:project_id, :user_type, :username, :version, :comment, :remote_address, :request_uuid, :association_id, :association_type]
    end
    if !options[:methods]
      options[:methods] = [:user_name] 
    end
    super(options)
  end
end

# Handle yaml issues
Object.class_eval <<-eorb, __FILE__, __LINE__ + 1
  alias :psych_to_yaml :to_yaml
eorb
require 'syck'
# Don't let Syck become the new default
Object.class_eval <<-eorb, __FILE__, __LINE__ + 1
    remove_const 'YAML' if defined? YAML
    YAML = Psych
    remove_method :to_yaml
    alias :to_yaml :psych_to_yaml
eorb
module ActiveRecord
  module Coders # :nodoc:
    class YAMLColumn # :nodoc:
      def load(yaml)
        return object_class.new if object_class != Object && yaml.nil?
        return yaml unless yaml.is_a?(String) && /^---/.match(yaml)
        if yaml.match(/.*\\x.*/)
          obj = Syck.load(yaml) # Use old version of yaml
          puts obj
        else # try new version first
          begin
            obj = YAML.load(yaml)
          rescue => e
            obj = Syck.load(yaml) # Use old version of yaml
          end
        end
        assert_valid_value(obj)
        obj ||= object_class.new if object_class != Object

        obj
      end
    end
  end
end