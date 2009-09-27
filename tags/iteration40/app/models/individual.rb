require 'digest/sha1'
class Individual < ActiveRecord::Base
  belongs_to :company
  has_and_belongs_to_many :projects
  belongs_to :selected_project, :class_name => "Project", :foreign_key => "selected_project_id"
  belongs_to :team
  has_many :stories, :dependent => :nullify
  has_many :tasks, :dependent => :nullify
  attr_accessible :login, :email, :first_name, :last_name, :password, :password_confirmation, :enabled, :role, :last_login, :accepted_agreement, :team_id, :phone_number, :notification_type, :company_id, :selected_project_id
  acts_as_audited :except => [:selected_project_id, :crypted_password, :salt, :remember_token, :remember_token_expires_at, :activation_code, :activated_at, :last_login, :accepted_agreement]

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email, :first_name, :last_name, :role, :notification_type
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 6..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 2..40
  validates_length_of       :first_name,    :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :last_name,    :maximum => 40, :allow_nil => true # Allow nil to workaround bug
  validates_length_of       :email,    :within => 6..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
  validates_numericality_of :role, :notification_type
  validates_format_of       :phone_number, :message => "must be a valid telephone number", :with => /^[\(\)0-9\- \+\.]{10,20}$/, :allow_nil => true, :allow_blank => true

  # Ensure that the individual's email address is validated.
  before_create :make_activation_code
  
  # Ensure that the password is encrypted
  before_save :encrypt_password

  Admin = 0
  ProjectAdmin = 1
  ProjectUser = 2
  ReadOnlyUser = 3
  
  NoNotifications = 0
  EmailNotifications = 1
  SMSNotifications = 2
  BothNotifications = 3

  # Authenticates an individual by their login name and unencrypted password.  Returns the individual or nil.
  def self.authenticate(login, password)
    # Authentication uses case insensitive login comparison (password is case sensitive)
    individual = find :first, :conditions => ['STRCMP( login, ?)=0 and activated_at IS NOT NULL and enabled', login] # need to get the salt
    individual && individual.authenticated?(password) ? individual : nil
  end

  # Answer if a password is valid for this individual.
  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  # Find the individual for a particular activation code and activate it.  Answer
  # the individual if successful or nil otherwise.
  def self.activate( activation_code )
    if activation_code && individual = find_by_activation_code(activation_code)
      individual.activate!
      individual
    end    
  end

  # Activate the user (i.e., we've validated that the email address for the individual is valid).
  def activate!
    self.activated_at = Time.now.utc
  end

  # Answer whether the individual has been activated.
  def activated?
    # the existence of an activation code means they have not been activated
    activated_at != nil
  end

  # Remember this individual on the browser for two weeks so that they don't have to log in.
  def remember_me
    remember_me_for 2.weeks
  end

  # Forget this individual on the browser, forcing log in.
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
  end

  # Answer whether we should still remember this individual.
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # Override attributes= to handle project_ids.
  def attributes=(new_attributes, guard_protected_attributes = true)
    keys_to_remove = []
    new_attributes.each_pair do |key, value|
      if key.to_sym == :project_id
        keys_to_remove << key
        changed_attributes['project_id'] = [project_ids, nil]
        projects.clear
        if (value)
          projects << Project.find(value)
        end
        changed_attributes['project_id'][1] = project_ids
      end
      if key.to_sym == :project_ids
        keys_to_remove << key
        changed_attributes['project_id'] = [project_ids, nil]
        projects.clear
        if (value)
          value.split(",").each {|project_id| projects << Project.find(project_id)}
        end
        changed_attributes['project_id'][1] = project_ids
      end
    end
    keys_to_remove.each {|key| new_attributes.delete(key)} # Prevents warning
    super(new_attributes, guard_protected_attributes)
  end

  # Answer how I should be displayed to the user.
  def name
    "#{first_name} #{last_name}"
  end

  # Override to_xml to exclude private attributes.
  def to_xml(options = {})
    if !options[:except]
      options[:except] = [:crypted_password, :salt, :remember_token, :remember_token_expires_at, :activation_code ]
    end
    if !options[:methods]
      options[:methods] = [:project_ids]
    end
    super(options)
  end

  # Prettier method name for xml.
  def activated
    activated?
  end
  
  def project
    selected_project
  end  

  def project_id
    selected_project_id
  end

  def selected_project
    selected_project_id ? Project.find(selected_project_id) : nil
  end
  
  def selected_project_id
    primitive = read_attribute(:selected_project_id)
    primitive ? primitive : (projects.empty? ? nil : projects[0].id)
  end
  
  def project_ids
    projects.collect {|project|project.id}.join(',')
  end

  # Answer the records for a particular user.
  def self.get_records(current_user)
    if current_user.role >= Individual::ProjectAdmin
      if current_user.is_premium
        find(:all, :include => [:projects], :conditions => ["individuals.company_id = ? and role in (1,2,3)", current_user.company_id], :order => 'first_name, last_name')
      else
        find(:all, :include => [:projects],
          :conditions => ["projects.id = ? and role in (1,2,3)", current_user.project_id], :order => 'first_name, last_name')
      end
    else
      find(:all, :include => [:projects], :order => 'first_name, last_name')
    end
  end

  # Only project admins or higher can create individuals.
  def authorized_for_create?(current_user)
    if current_user.role <= Individual::Admin
      true
    elsif current_user.role <= Individual::ProjectAdmin
      (current_user.project_id == project_id || (current_user.is_premium && current_user.company_id == company_id)) && role != Individual::Admin
    else
      false
    end
  end

  # Answer whether the user is authorized to see me.
  def authorized_for_read?(current_user)
    case current_user.role
      when Individual::Admin then true
      else (current_user.project_id == project_id || (current_user.is_premium && current_user.company_id == company_id)) && role != Individual::Admin
    end
  end

  # Answer whether the user is authorized for update.
  def authorized_for_update?(current_user)
    case current_user.role
      when Individual::Admin then true
      when Individual::ProjectAdmin then (current_user.project_id == project_id || (current_user.is_premium && current_user.company_id == company_id)) && role != Individual::Admin
      when Individual::ProjectUser then current_user.id == id
      else false
    end
  end

  # Answer whether the user is authorized for delete.
  def authorized_for_destroy?(current_user)
    case current_user.role
      when Individual::Admin then id != current_user.id
      when Individual::ProjectAdmin then id != current_user.id && (current_user.project_id == project_id || (current_user.is_premium && current_user.company_id == company_id)) && role != Individual::Admin
      else false
    end
  end
   
  # Too many users have been added.
  def count_exceeded
    errors.add_to_base("Too many users exist to make this change.  To address the issue, delete or disable a user or contact support to extend your limits.")
  end

  # Answer whether I am enabled for premium services.
  def is_premium
    projects.detect {|project| project.is_premium}
  end

  # Notify that something has occurred.
  def send_notification(message)
    if is_premium
      if notification_type == EmailNotifications || notification_type == BothNotifications
        PLANIGLE_EMAIL_NOTIFIER.send_notification(email, message)
      end
  
      if (notification_type == SMSNotifications || notification_type == BothNotifications) && phone_number && phone_number != ''
        PLANIGLE_SMS_NOTIFIER.send_notification(phone_number, message)
      end
    end
  end

protected

  # Remember this individual on the browser for the specified amount of time so that they
  # don't have to log in.
  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  # Remember this individual on the browser until the specified time so that they
  # don't have to log in.
  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
  end

  # Returns the password encrypted with my salt.
  def encrypt(password)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypt the password before saving.
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  # Answer if the password is being changed / needs to be changed.
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  # Set my activation code.
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  # Ensure that the premium limit is not exceeded.
  def validate_on_create
    if will_impact_limits
      count_exceeded
    end
  end
  
  # Ensure that the premium limit is not exceeded.
  def validate_on_update
    if will_impact_limits
      if (changed_attributes['project_id']) ||
        (changed_attributes['role'] && changed_attributes['role'][0] >= ReadOnlyUser && changed_attributes['role'][1] < ReadOnlyUser) ||
        (changed_attributes['enabled'] && !changed_attributes['enabled'][0] && changed_attributes['enabled'][1])
        count_exceeded
      end
    end
  end

  # Answer whether if saved, I will cause the premium limits to be exceeded.
  def will_impact_limits
    role < ReadOnlyUser && enabled && projects.detect {|project| !project.can_add_users}
  end

  # Add custom validation of the role field.
  def validate
    if role && (role < Admin || role > ReadOnlyUser)
      errors.add(:role, 'is invalid')
    end
    
    if role && (role > Admin && !company_id )
      errors.add(:company, 'must be set for users who are not admins')
    end
    
    if role && (role > Admin && projects.empty? )
      errors.add(:project, 'must be set for users who are not admins')
    end

    if notification_type && (notification_type < NoNotifications || notification_type > BothNotifications)
      errors.add(:notification_type, 'is invalid')
    end    
    
    if notification_type && (notification_type == SMSNotifications || notification_type == BothNotifications) && (!phone_number || phone_number == '')
      errors.add(:phone_number, 'must be set in order to send SMS notifications')
    end    
    
    projects.each do |project|
      if company_id != project.company_id
        errors.add(:project, 'must be associated with company')
      end
    end

    if team && (!projects.detect{|project|team.project == project})
      errors.add(:team, 'must be associated with project')
    end
    
    if selected_project && company && selected_project.company != company && role > Admin
      if errors.empty?
        self.selected_project_id = nil
      end
    end
  end
end