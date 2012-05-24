SITE_CONFIG = YAML::load(File.open("#{RAILS_ROOT}/config/site_config.yml")).with_indifferent_access

def config_option(p, env = nil) 
	env ||= RAILS_ENV
  # WRB - Changed to allow no settings for an environment
	SITE_CONFIG[env] = {} if SITE_CONFIG[env].nil?	
	inherit_env = SITE_CONFIG[env]["inherit"]
	SITE_CONFIG[env][p] || (inherit_env && config_option(p, inherit_env))
end

# WRB - Added to enable easier testing of config options
def config_option_set(p, value, env = nil)
  env ||= RAILS_ENV
  SITE_CONFIG[env] = {} if SITE_CONFIG[env].nil?  
  SITE_CONFIG[env][p] = value
end