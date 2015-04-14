require 'net/ldap'

# Use the ruby-net-ldap gem to authenticate with LDAP.
class Authenticate
  def self.ldap(username, password)
    ldap = Net::LDAP.new
    ldap.port = Rails.configuration.ldap_port.to_i
    ldaphost = Rails.configuration.ldap_host
    ldap.host = ldaphost
    suffix = Rails.configuration.domain_suffix
    searchbase = Rails.configuration.ldap_search_base
    attrs = []
    filter = Net::LDAP::Filter.eq( "uid", username ) | Net::LDAP::Filter.eq( "mail", "#{username}#{suffix}" ) | Net::LDAP::Filter.eq( "mailalternateaddress", "#{username}#{suffix}")
    entry = ldap.search( :base => searchbase, :attributes => attrs, :filter => filter, :return_result => true ).first
    ldap.auth entry.dn, password
    ldap.bind
  end
end